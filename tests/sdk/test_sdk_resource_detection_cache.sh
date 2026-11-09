#!/bin/sh
set -e

/opt/opentelemetry_shell/venv/bin/python - <<'PY'
import importlib.util
import json
import os
import tempfile
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

sdk.handle('shell', '1', 'SPAN_NOOP', None)
sdk.handle('shell', '1', 'COUNTER_NOOP', None)
sdk.handle('shell', '1', 'LOG_NOOP', None)
from opentelemetry.trace import get_tracer_provider
from opentelemetry.metrics import get_meter_provider
from opentelemetry._logs import get_logger_provider
assert get_tracer_provider().resource == baseline
assert get_meter_provider()._sdk_config.resource == baseline
assert get_logger_provider().resource == baseline
PY
