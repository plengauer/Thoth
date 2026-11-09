#!/bin/sh
set -e

/opt/opentelemetry_shell/venv/bin/python - <<'PY'
import importlib.util
import json
import os
import subprocess
import tempfile
import time
from unittest.mock import patch
from urllib.parse import unquote

from opentelemetry.sdk.resources import Resource, ResourceDetector

spec = importlib.util.spec_from_file_location('sdk', '/usr/share/opentelemetry_shell/sdk.py')
sdk = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sdk)

class Detector(ResourceDetector):
    calls = 0
    def detect(self):
        Detector.calls += 1
        return Resource({'cloud.resource_id': 'a,b=c/d e', 'host.cpu.count': 42, 'host.aliases': ['a', 'b']})

class EmptyDetector(ResourceDetector):
    def detect(self):
        return Resource({})

os.environ.update({
    'OTEL_RESOURCE_ATTRIBUTES': 'user.value=x%2Cy%3Dz%2Fw%20v',
    'OTEL_SERVICE_NAME': 'test-service',
    'OTEL_TRACES_EXPORTER': 'none',
    'OTEL_METRICS_EXPORTER': 'none',
    'OTEL_LOGS_EXPORTER': 'none',
})
os.environ.pop('OTEL_SHELL_RESOURCE_DETECTION_CACHE', None)
os.environ.pop('OTEL_DISABLE_RESOURCE_DETECTION', None)
sdk.resource.update({'process.pid': 123, 'service.name': 'child-service'})

with patch.object(sdk, 'guess_cloud_resource_detectors', return_value=[Detector()]), \
     patch('opentelemetry_resourcedetector_docker.DockerResourceDetector', EmptyDetector), \
     patch('opentelemetry_resourcedetector_kubernetes.KubernetesResourceDetector', EmptyDetector), \
     patch('opentelemetry.sdk.resources.OsResourceDetector', EmptyDetector):
    sdk.handle('shell', '1', 'INIT', None)
    baseline = sdk.final_resources
    Detector.calls = 0
    with tempfile.NamedTemporaryFile() as output:
        sdk.dump_resource_attributes(output.name)
        snapshot = json.load(output)
    assert Detector.calls == 1

os.environ['OTEL_DISABLE_RESOURCE_DETECTION'] = 'TRUE'
with patch.object(sdk, 'guess_cloud_resource_detectors', side_effect=AssertionError('unexpected detection')):
    sdk.handle('shell', '1', 'INIT', None)
assert 'cloud.resource_id' not in sdk.final_resources.attributes
del os.environ['OTEL_DISABLE_RESOURCE_DETECTION']

attributes = dict(item.split('=', 1) for item in snapshot['attributes'].split(','))
assert unquote(attributes['cloud.resource_id']) == 'a,b=c/d e'
assert unquote(attributes['user.value']) == 'x,y=z/w v'
os.environ['OTEL_RESOURCE_ATTRIBUTES'] = snapshot['attributes'] + ',' + os.environ['OTEL_RESOURCE_ATTRIBUTES']
os.environ['OTEL_SHELL_RESOURCE_DETECTION_CACHE'] = snapshot['cache']
with patch.object(sdk, 'detect_resources', side_effect=AssertionError('unexpected detection')), \
     patch.object(Resource, 'create', side_effect=AssertionError('unexpected Resource.create')):
    sdk.handle('shell', '1', 'INIT', None)
assert sdk.final_resources == baseline
assert sdk.final_resources.attributes['host.cpu.count'] == 42
assert sdk.final_resources.attributes['host.aliases'] == ('a', 'b')
assert sdk.final_resources.attributes['process.pid'] == 123
assert sdk.final_resources.attributes['service.name'] == 'child-service'
os.environ['OTEL_RESOURCE_ATTRIBUTES'] += ',later.value=after%2Cinit'
with patch.object(sdk, 'detect_resources', side_effect=AssertionError('unexpected detection')):
    sdk.handle('shell', '1', 'INIT', None)
assert sdk.final_resources.attributes['later.value'] == 'after,init'
os.environ['OTEL_RESOURCE_ATTRIBUTES'] = os.environ['OTEL_RESOURCE_ATTRIBUTES'].rsplit(',', 1)[0]
sdk.handle('shell', '1', 'INIT', None)

sdk.handle('shell', '1', 'SPAN_NOOP', None)
sdk.handle('shell', '1', 'COUNTER_NOOP', None)
sdk.handle('shell', '1', 'LOG_NOOP', None)
from opentelemetry.trace import get_tracer_provider
from opentelemetry.metrics import get_meter_provider
from opentelemetry._logs import get_logger_provider
assert get_tracer_provider().resource == baseline
assert get_meter_provider()._sdk_config.resource == baseline
assert get_logger_provider().resource == baseline

with tempfile.TemporaryDirectory() as directory:
    factory_pipe = os.path.join(directory, 'factory')
    os.mkfifo(factory_pipe)
    factory_env = os.environ.copy()
    factory_env.update({
        'OTEL_TRACES_EXPORTER': 'console',
        'OTEL_METRICS_EXPORTER': 'console',
        'OTEL_LOGS_EXPORTER': 'console',
        'OTEL_EXPERIMENTAL_RESOURCE_DETECTORS': 'thoth_missing_detector',
    })
    with open(os.path.join(directory, 'out'), 'w+') as output, open(os.path.join(directory, 'err'), 'w+') as errors:
        factory = subprocess.Popen(
            ['/opt/opentelemetry_shell/venv/bin/python', '../actions/instrument/job/sdk_factory.py', factory_pipe],
            env=factory_env, stdout=output, stderr=errors,
        )
        try:
            for pid in (111, 222):
                commands = os.path.join(directory, 'commands')
                response = os.path.join(directory, 'response')
                with open(commands, 'w') as stream:
                    stream.write(
                        f'RESOURCE_ATTRIBUTE int process.pid={pid}\n'
                        'RESOURCE_ATTRIBUTE string service.name=child-service\n'
                        'INIT\n'
                        f'SPAN_START {response} - - auto INTERNAL factory-span-{pid}\n'
                        'SPAN_END 0 auto\n'
                        f'COUNTER_CREATE {response} counter factory.counter.{pid} 1 test\n'
                        f'OBSERVATION_CREATE {response} 1\n'
                        'COUNTER_OBSERVE 0 0\n'
                        f'LOG_RECORD - auto 9 factory-log-{pid}\n'
                    )
                with open(factory_pipe, 'w') as stream:
                    stream.write(f'shell 1 {commands}\n')
                deadline = time.monotonic() + 30
                while True:
                    output.seek(0)
                    text = output.read()
                    if all(name in text for name in (f'factory-span-{pid}', f'factory.counter.{pid}', f'factory-log-{pid}')):
                        break
                    if time.monotonic() >= deadline:
                        errors.seek(0)
                        raise AssertionError((text, errors.read()))
                    time.sleep(0.1)
                decoder = json.JSONDecoder()
                objects = []
                while text.strip():
                    item, end = decoder.raw_decode(text.lstrip())
                    text = text.lstrip()[end:]
                    objects.append(item)
                resources = []
                for item in objects:
                    if item.get('name') == f'factory-span-{pid}' or item.get('body') == f'factory-log-{pid}':
                        resources.append(item['resource']['attributes'])
                    for metric_resource in item.get('resource_metrics', []):
                        if f'factory.counter.{pid}' in json.dumps(metric_resource):
                            resources.append(metric_resource['resource']['attributes'])
                assert len(resources) == 3, resources
                for attributes in resources:
                    assert attributes['cloud.resource_id'] == 'a,b=c/d e'
                    assert attributes['host.cpu.count'] == 42
                    assert attributes['host.aliases'] == ['a', 'b']
                    assert attributes['user.value'] == 'x,y=z/w v'
                    assert attributes['process.pid'] == pid
                    assert attributes['service.name'] == 'child-service'
            errors.seek(0)
            error_output = errors.read()
            assert 'thoth_missing_detector' not in error_output, error_output
        finally:
            with open(factory_pipe, 'w') as stream:
                stream.write('EOF\n')
            factory.wait(timeout=30)
PY
