import sys
import os
import time
import traceback
import json
import requests
from datetime import datetime, timezone
import functools
import hashlib

import opentelemetry

from opentelemetry.sdk.resources import Resource, ResourceDetector, OTELResourceDetector, OsResourceDetector, get_aggregated_resources
from opentelemetry_resourcedetector_docker import DockerResourceDetector
from opentelemetry_resourcedetector_kubernetes import KubernetesResourceDetector

from opentelemetry.trace import SpanKind
from opentelemetry.sdk.trace import Span, StatusCode, TracerProvider, sampling, id_generator
from opentelemetry.sdk.trace.export import SimpleSpanProcessor, BatchSpanProcessor, ConsoleSpanExporter
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.trace.propagation.tracecontext import TraceContextTextMapPropagator

from opentelemetry.metrics import Observation
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader, ConsoleMetricExporter
from opentelemetry.exporter.otlp.proto.http.metric_exporter import OTLPMetricExporter

from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler, LogRecord
from opentelemetry.sdk._logs._internal import SeverityNumber
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor, ConsoleLogExporter
from opentelemetry.exporter.otlp.proto.http._log_exporter import OTLPLogExporter

class GithubActionResourceDetector(ResourceDetector):
    def detect(self) -> Resource:
        try:
            if not 'GITHUB_RUN_ID' in os.environ:
                return Resource.create({});
            return Resource.create({
                'github.repository.id': os.environ.get('GITHUB_REPOSITORY_ID', ''),
                'github.repository.name': os.environ.get('GITHUB_REPOSITORY', '/').split('/', 1)[1],
                'github.repository.owner.id': os.environ.get('GITHUB_REPOSITORY_OWNER_ID', ''),
                'github.repository.owner.name': os.environ.get('GITHUB_REPOSITORY_OWNER', ''),
                'github.actions.workflow.ref': os.environ.get('GITHUB_WORKFLOW_REF', ''),
                'github.actions.workflow.sha': os.environ.get('GITHUB_WORKFLOW_SHA', ''),
                'github.actions.workflow.name': os.environ.get('GITHUB_WORKFLOW', ''),
            })
        except:
            return Resource.create({})

class AwsEC2ResourceDetector(ResourceDetector):
    def detect(self) -> Resource:
        try:
            token = requests.put('http://169.254.169.254/latest/api/token', headers={ 'X-aws-ec2-metadata-token-ttl-seconds': '60' }, timeout=5).text
            identity = requests.get('http://169.254.169.254/latest/dynamic/instance-identity/document', headers={ 'X-aws-ec2-metadata-token': token }, timeout=5).json()
            hostname = requests.get('http://169.254.169.254/latest/meta-data/hostname', headers={ 'X-aws-ec2-metadata-token': token }, timeout=5).text
            return Resource.create({
                'cloud.provider': 'aws',
                'cloud.platform': 'aws_ec2',
                'cloud.account.id': identity['accountId'],
                'cloud.region': identity['region'],
                'cloud.availability_zone': identity['availabilityZone'],
                'host.id': identity['instanceId'],
                'host.type': identity['instanceType'],
                'host.name': hostname
            })
        except:
            return Resource.create({})

class OracleResourceDetector(ResourceDetector):
    def detect(self) -> Resource:
        try:
            metadata = self.fetch_metadata()
            resource = Resource.create({
                "cloud.provider": "oracle",
                "cloud.region": metadata['region'],
                "cloud.availability_zone": metadata['availabilityDomain'],
                "cloud.account_id": metadata['tenantId'],
                "host.type": metadata['shape'],
                "host.name": metadata['hostname'],
                "host.id": metadata['id'],
                "host.image_id": metadata['image']
            })
            return resource
        except Exception:
            return Resource({})

    def fetch_metadata(self):
        response = requests.get('http://169.254.169.254/opc/v1/instance/', headers={'Authorization': 'Bearer Oracle'})
        response.raise_for_status()  # Raise an exception for 4xx or 5xx status codes
        return response.json()

class MyIdGenerator(id_generator.RandomIdGenerator):
    trace_id = None
    span_id = None

    def __init__(self):
        traceparent = os.environ.get('OTEL_ID_GENERATOR_OVERRIDE_TRACEPARENT', None)
        if traceparent:
            context = opentelemetry.trace.get_current_span(TraceContextTextMapPropagator().extract({'traceparent': traceparent})).get_span_context()
            self.trace_id = context.trace_id
            self.span_id = context.span_id
    
    def generate_trace_id(self):
        if self.trace_id:
            trace_id = self.trace_id
            self.trace_id = None
            return trace_id
        else:
            return super(MyIdGenerator, self).generate_trace_id()
    
    def generate_span_id(self):
        if self.span_id:
            span_id = self.span_id
            self.span_id = None
            return span_id
        else:
            return super(MyIdGenerator, self).generate_span_id()

resource = {}
spans = {}
next_span_id = 0
events = {}
next_event_id = 0
links = {}
next_link_id = 0
counters = {}
next_counter_id = 0
observations = {}
next_observation_id = 0
delayed_observations = {}

auto_end = False

def main():
    scope = sys.argv[1]
    version = sys.argv[2]
    for line in sys.stdin:
        line = line.strip()
        if len(line) == 0:
            continue
        tokens = line.split(' ', 1)
        tokens = [token for token in tokens if token]
        try:
            handle(scope, version, tokens[0], tokens[1] if len(tokens) > 1 else None)
        except EOFError:
            sys.exit(0)
        except:
            print('SDK Error: ' + line, file=sys.stderr)
            traceback.print_exc()
    try:
        handle(scope, version, 'SHUTDOWN', None)
    except EOFError:
        sys.exit(0)
    except:
        pass

def handle(scope, version, command, arguments):
    global auto_end
    if command == 'RESOURCE_ATTRIBUTE':
        tokens = arguments.split(' ', 1)
        type = tokens[0]
        arguments = tokens[1]
        tokens = arguments.split('=', 1)
        key = tokens[0]
        value = tokens[1]
        resource[key] = convert_type(type, value)
    elif command == 'INIT':
        final_resources = get_aggregated_resources([
                AwsEC2ResourceDetector(),
                OracleResourceDetector(),
                KubernetesResourceDetector(),
                DockerResourceDetector(),
                GithubActionResourceDetector(),
                OsResourceDetector(),
                OTELResourceDetector(),
            ]).merge(Resource.create(resource)) if os.environ.get('OTEL_DISABLE_RESOURCE_DETECTION', 'FALSE') == 'FALSE' else Resource.create(resource)

        traces_exporters = os.environ.get('OTEL_TRACES_EXPORTER', 'otlp')
        metrics_exporters = os.environ.get('OTEL_METRICS_EXPORTER', 'otlp')
        logs_exporters = os.environ.get('OTEL_LOGS_EXPORTER', 'otlp')
        propagator = os.environ.get('OTEL_PROPAGATORS', 'tracecontext')
        sampling_strategy = os.environ.get('OTEL_TRACES_SAMPLER', 'parentbased_always_on')
        sampling_strategy_arg = os.environ.get('OTEL_TRACES_SAMPLER_ARG', '1.0')

        if propagator != 'tracecontext':
          raise Exception('Unsupported propagator: ' + propagator)

        if traces_exporters:
            sampler = None
            if sampling_strategy == 'always_on':
                sampler = sampling.DEFAULT_ON
            elif sampling_strategy == 'always_off':
                sampler = sampling.DEFAULT_OFF
            elif sampling_strategy == 'traceidratio':
                sampler = sampling.TradeIdRatioBased(float(sampling_strategy_arg))
            elif sampling_strategy == 'parentbased_always_on':
                sampler = sampling.ParentBased(sampling.DEFAULT_ON)
            elif sampling_strategy == 'parentbased_always_off':
                sampler = sampling.ParentBased(sampling.DEFAULT_OFF)
            elif sampling_strategy == 'parentbased_traceidratio':
                sampler = sampling.ParentBased(sampling.TradeIdRatioBased(float(sampling_strategy_arg)))
            else:
                raise Exception('Unknown sampler: ' + sampler)
            tracer_provider = TracerProvider(sampler=sampler, resource=final_resources, id_generator=MyIdGenerator())
            for traces_exporter in traces_exporters.split(','):
                if traces_exporter == '':
                    pass
                elif traces_exporter == 'none':
                    pass
                elif traces_exporter == 'console':
                    tracer_provider.add_span_processor(SimpleSpanProcessor(ConsoleSpanExporter()))
                elif traces_exporter == 'otlp':
                    tracer_provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter()))
                else:
                    raise Exception('Unknown exporter: ' + traces_exporter)
            opentelemetry.trace.set_tracer_provider(tracer_provider)

        if metrics_exporters:
            metric_readers = []
            for metrics_exporter in metrics_exporters.split(','):
                if metrics_exporter == '':
                    pass
                elif metrics_exporter == 'none':
                    pass
                elif metrics_exporter == 'console':
                    metric_readers.append(PeriodicExportingMetricReader(ConsoleMetricExporter()))
                elif metrics_exporter == 'otlp':
                    metric_readers.append(PeriodicExportingMetricReader(OTLPMetricExporter()))
                else:
                    raise Exception('Unknown exporter: ' + metrics_exporter)
            opentelemetry.metrics.set_meter_provider(MeterProvider(metric_readers = metric_readers, resource=final_resources))

        if logs_exporters:
            logger_provider = LoggerProvider(resource=final_resources)
            for logger_exporter in logs_exporters.split(','):
                if logger_exporter == '':
                    pass
                elif logger_exporter == 'none':
                    pass
                elif logger_exporter == 'console':
                    logger_provider.add_log_record_processor(BatchLogRecordProcessor(ConsoleLogExporter()))
                elif logger_exporter == 'otlp':
                    logger_provider.add_log_record_processor(BatchLogRecordProcessor(OTLPLogExporter()))
                else:
                    raise Exception('Unknown exporter: ' + logger_exporter)
            opentelemetry._logs.set_logger_provider(logger_provider)

    elif command == 'SHUTDOWN':
        if not auto_end:
            for span in spans.values():
                console.log("DEBUG DEBUG DEBUG still active span: " + span.name)
        if auto_end:
            for span in spans.values():
                span.end()
        opentelemetry.trace.get_tracer_provider().shutdown()
        opentelemetry.metrics.get_meter_provider().shutdown()
        opentelemetry._logs.get_logger_provider().shutdown()
        raise EOFError
    elif command == 'SPAN_START':
        global next_span_id
        tokens = arguments.split(' ', 5)
        response_path = tokens[0]
        traceparent = tokens[1]
        tracestate = tokens[2]
        start_time = tokens[3]
        kind = tokens[4]
        name = tokens[5]
        span_id = next_span_id
        next_span_id = next_span_id + 1
        span = opentelemetry.trace.get_tracer(scope, version).start_span(name, kind=SpanKind[kind.upper()], context=TraceContextTextMapPropagator().extract({'traceparent': traceparent, 'tracestate': tracestate}), start_time=parse_time(start_time))
        spans[str(span_id)] = span
        with open(response_path, 'w') as response:
            response.write(str(span_id))
        auto_end = False
    elif command == 'SPAN_END':
        tokens = arguments.split(' ', 1)
        span_id = tokens[0]
        end_time = tokens[1]
        span : Span = spans[span_id]
        span.end(end_time=parse_time(end_time))
        del spans[span_id]
    elif command == 'SPAN_HANDLE':
        tokens = arguments.split(' ', 1)
        response_path = tokens[0]
        traceparent = tokens[1]
        context = opentelemetry.trace.get_current_span(TraceContextTextMapPropagator().extract({'traceparent': traceparent})).get_span_context()
        for span_id, span in spans.items():
            if span.context.span_id == context.span_id:
                with open(response_path, 'w') as response:
                    response.write(str(span_id))
                    return
    elif command == 'SPAN_AUTO_END':
        auto_end = True
    elif command == 'SPAN_NAME':
        tokens = arguments.split(' ', 1)
        span_id = tokens[0]
        name = tokens[1]
        span : Span = spans[span_id]
        span.update_name(name)
    elif command == 'SPAN_ERROR':
        span : Span = spans[arguments]
        span.set_status(StatusCode.ERROR)
    elif command == 'SPAN_ATTRIBUTE':
        tokens = arguments.split(' ', 2)
        span_id = tokens[0]
        type = tokens[1]
        keyvaluepair = tokens[2]
        tokens = keyvaluepair.split('=', 1)
        key = tokens[0]
        value = tokens[1]
        if value == '':
            return
        span : Span = spans[span_id]
        span.set_attribute(key, convert_type(type, value, span.attributes.get(key)))
    elif command == 'SPAN_TRACEPARENT':
        tokens = arguments.split(' ', 1)
        response_path = tokens[0]
        if len(tokens) == 1:
            with open(response_path, 'w') as response:
                response.write('')
                return
        span_id = tokens[1]
        if not span_id in spans:
            with open(response_path, 'w') as response:
                response.write('')
                return
        span : Span = spans[span_id]
        carrier = {}
        TraceContextTextMapPropagator().inject(carrier, opentelemetry.trace.set_span_in_context(span, None))
        with open(response_path, 'w') as response:
            response.write(carrier.get('traceparent', ''))
    elif command == 'EVENT_CREATE':
        global next_event_id
        tokens = arguments.split(' ', 1)
        response_path = tokens[0]
        event_name = tokens[1]
        event_id = str(next_event_id)
        next_event_id = next_event_id + 1
        events[event_id] = { 'name': event_name, 'attributes': {} }
        with open(response_path, 'w') as response:
            response.write(event_id)
    elif command == 'EVENT_ATTRIBUTE':
        tokens = arguments.split(' ', 2)
        event_id = tokens[0]
        type = tokens[1]
        keyvaluepair = tokens[2]
        tokens = keyvaluepair.split('=', 1)
        key = tokens[0]
        value = tokens[1]
        if value == '':
            return
        events[event_id]['attributes'][key] = convert_type(type, value)
    elif command == 'EVENT_ADD':
        tokens = arguments.split(' ', 2)
        event_id = tokens[0]
        span_id = tokens[1]
        event = events[event_id]
        spans[span_id].add_event(event['name'], event['attributes'])
        del events[event_id]
    elif command == 'LINK_CREATE':
        global next_link_id
        tokens = arguments.split(' ', 3)
        response_path = tokens[0]
        traceparent = tokens[1]
        tracestate = tokens[2]
        # third is dummy to not be stripped away
        link_context = opentelemetry.trace.get_current_span(TraceContextTextMapPropagator().extract({'traceparent': traceparent, 'tracestate': tracestate})).get_span_context()
        link_id = str(next_link_id)
        next_link_id = next_link_id + 1
        links[link_id] = { 'context': link_context, 'attributes': {} }
        with open(response_path, 'w') as response:
            response.write(link_id)
    elif command == 'LINK_ATTRIBUTE':
        tokens = arguments.split(' ', 2)
        link_id = tokens[0]
        type = tokens[1]
        keyvaluepair = tokens[2]
        tokens = keyvaluepair.split('=', 1)
        key = tokens[0]
        value = tokens[1]
        if value == '':
            return
        links[link_id]['attributes'][key] = convert_type(type, value)
    elif command == 'LINK_ADD':
        tokens = arguments.split(' ', 1)
        link_id = tokens[0]
        span_id = tokens[1]
        link = links[link_id]
        spans[span_id].add_link(link['context'], link['attributes'])
        del links[link_id]
    elif command == 'COUNTER_CREATE':
        global next_counter_id
        tokens = arguments.split(' ', 4)
        response_path = tokens[0]
        type = tokens[1]
        name = tokens[2]
        unit = tokens[3]
        description = tokens[4]
        meter = opentelemetry.metrics.get_meter(scope, version)
        counter_id = str(next_counter_id)
        if type == 'counter':
            counters[counter_id] = meter.create_counter(name, unit=unit, description=description)
        elif type == 'up_down_counter':
            counters[counter_id] = meter.create_up_down_counter(name, unit=unit, description=description)
        elif type == 'gauge':
            counters[counter_id] = meter.create_gauge(name, unit=unit, description=description)
        elif type == 'observable_counter':
            delayed_observations[counter_id] = {}
            counters[counter_id] = meter.create_observable_counter(name, [ functools.partial(observable_counter_callback, counter_id) ], unit=unit, description=description)
        elif type == 'observable_up_down_counter':
            delayed_observations[counter_id] = {}
            counters[counter_id] = meter.create_observable_up_down_counter(name, [ functools.partial(observable_counter_callback, counter_id) ], unit=unit, description=description)
        elif type == 'observable_gauge':
            delayed_observations[counter_id] = {}
            counters[counter_id] = meter.create_observable_gauge(name, [ functools.partial(observable_counter_callback, counter_id) ], unit=unit, description=description)
        else:
            raise Exception('Unknown counter type: ' + type)
        next_counter_id = next_counter_id + 1
        with open(response_path, 'w') as response:
            response.write(counter_id)
    elif command == 'COUNTER_OBSERVE':
        tokens = arguments.split(' ', 1)
        counter_id = tokens[0]
        observation_id = tokens[1]
        observation = observations[observation_id]
        counter = counters[counter_id]
        if hasattr(counter, 'add'):
            counter.add(observation['amount'], observation['attributes'])
        elif hasattr(counter, 'set'):
            counter.set(observation['amount'], observation['attributes'])
        else:
            delayed_observations[counter_id][hashlib.sha256(json.dumps(observation['attributes'], sort_keys=True).encode('utf-8')).hexdigest()] = observation
        del observations[str(observation_id)]
    elif command == 'OBSERVATION_CREATE':
        global next_observation_id
        tokens = arguments.split(' ', 1)
        response_path = tokens[0]
        amount = tokens[1]
        observation_id = str(next_observation_id)
        next_observation_id = next_observation_id + 1
        observations[observation_id] = { 'amount': convert_type('auto', amount), 'attributes': {} }
        with open(response_path, 'w') as response:
            response.write(observation_id)
    elif command == 'OBSERVATION_ATTRIBUTE':
        tokens = arguments.split(' ', 2)
        observation_id = tokens[0]
        type = tokens[1]
        keyvaluepair = tokens[2]
        tokens = keyvaluepair.split('=', 1)
        key = tokens[0]
        value = tokens[1]
        if value == '':
            return
        observations[str(observation_id)]['attributes'][key] = convert_type(type, value)
    elif command == 'LOG_RECORD':
        tokens = arguments.split(' ', 3)
        traceparent = tokens[0]
        log_time = tokens[1]
        log_severity = tokens[2]
        line = tokens[3] if len(tokens) > 3 else ""
        if len(line) == 0:
            return
        context = TraceContextTextMapPropagator().extract({'traceparent': traceparent})
        logger = opentelemetry._logs.get_logger(scope, version)
        record = LogRecord(
            timestamp=parse_time(log_time),
            context=context,
            severity_text='unspecified',
            severity_number=SeverityNumber(int(log_severity)),
            body=line,
            resource=logger.resource if hasattr(logger, "resource") else Resource.create({}),
        )
        logger.emit(record)
    else:
        return

def observable_counter_callback(counter_id, _):
    for observation in delayed_observations[counter_id].values():
        yield Observation(observation['amount'], observation['attributes'])

def parse_time(time_string):
    if time_string == 'auto':
        return int(time.time() * 1e9)
    elif '-' in time_string and ':' in time_string and 'T' in time_string:
        time_string = time_string.rstrip('Z')
        try:
            time_part, fractional_seconds_part = time_string.split('.')
        except ValueError:
            time_part = time_string
            fractional_seconds_part = '0'
        return int(datetime.strptime(time_part, "%Y-%m-%dT%H:%M:%S").replace(tzinfo=timezone.utc).timestamp() * int(1e9)) + int(fractional_seconds_part.ljust(9, '0')[:9])
    elif '.' in time_string:
        seconds_part, fractional_seconds_part = time_string.split('.')
        return int(seconds_part) * int(1e9) + int(fractional_seconds_part.ljust(9, '0')[:9])
    else:
        return int(time_string)

def convert_type(type, value, base=None):
    if type == 'string':
        return value
    elif type == 'int':
        return int(value)
    elif type == '+int':
        if base:
            return base + convert_type('int', value)
        else:
            return convert_type('int', value)
    elif type == 'float':
        return float(value)
    elif type == '+float':
        if base:
            return base + convert_type('float', value)
        else:
            return convert_type('float', value)
    elif type == 'string[1]':
        return [ value ];
    elif type == '+string[1]':
        if base:
            return list(base) + convert_type('string[1]', value)
        else:
            return convert_type('string[1]', value)
    elif type == 'auto':
        try:
            return int(value)
        except:
            pass
        try:
            return float(value)
        except:
            pass
        return value
    else:
        raise Exception('Unknown type: ' + type)

if __name__ == "__main__":
    main()

