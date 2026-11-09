#!/bin/sh
set -e

/opt/opentelemetry_shell/venv/bin/python - <<'PY'
import importlib.util
import io
import json
import os
import subprocess
import tempfile
import time
from contextlib import redirect_stdout
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
})
os.environ.pop('OTEL_DISABLE_RESOURCE_DETECTION', None)
os.environ.pop('OTEL_EXPERIMENTAL_RESOURCE_DETECTORS', None)

with tempfile.TemporaryDirectory() as directory:
    attributes_path = os.path.join(directory, 'resource_attributes')
    output = io.StringIO()
    with patch.object(sdk, 'guess_cloud_resource_detectors', return_value=[Detector()]), \
         patch('opentelemetry_resourcedetector_docker.DockerResourceDetector', EmptyDetector), \
         patch('opentelemetry_resourcedetector_kubernetes.KubernetesResourceDetector', EmptyDetector), \
         patch('opentelemetry.sdk.resources.OsResourceDetector', EmptyDetector), \
         redirect_stdout(output):
        try:
            sdk.run('shell', '1', io.StringIO(f'INIT\nDUMP_RESOURCE_ATTRIBUTES {attributes_path}\n'))
        except SystemExit as error:
            assert error.code == 0
    assert Detector.calls == 1
    assert output.getvalue() == ''
    with open(attributes_path) as attributes_file:
        dumped_attributes = attributes_file.read()
    attributes = dict(item.split('=', 1) for item in dumped_attributes.split(','))
    assert unquote(attributes['cloud.resource_id']) == 'a,b=c/d e'
    assert unquote(attributes['user.value']) == 'x,y=z/w v'
    assert 'telemetry.sdk.language' not in attributes
    assert 'service.instance.id' not in attributes
    assert 'host.cpu.count' not in attributes
    assert sdk.final_resources.attributes['host.cpu.count'] == 42

    os.environ['OTEL_RESOURCE_ATTRIBUTES'] = dumped_attributes + ',later.value=after%2Cinit'
    os.environ['OTEL_DISABLE_RESOURCE_DETECTION'] = 'TRUE'
    sdk.resource.update({'process.pid': 123, 'service.name': 'child-service'})
    with patch.object(sdk, 'guess_cloud_resource_detectors', side_effect=AssertionError('unexpected detection')):
        sdk.handle('shell', '1', 'INIT', None)
    assert sdk.final_resources.attributes['cloud.resource_id'] == 'a,b=c/d e'
    assert 'host.cpu.count' not in sdk.final_resources.attributes
    assert sdk.final_resources.attributes['user.value'] == 'x,y=z/w v'
    assert sdk.final_resources.attributes['later.value'] == 'after,init'
    assert sdk.final_resources.attributes['process.pid'] == 123
    assert sdk.final_resources.attributes['service.name'] == 'child-service'

    with open(os.path.join(directory, 'output'), 'w+') as output, open(os.path.join(directory, 'errors'), 'w+') as errors:
        environment = os.environ.copy()
        environment.update({'OTEL_TRACES_EXPORTER': 'console'})
        os.mkfifo(os.path.join(directory, 'factory'))
        factory = subprocess.Popen(
            ['/opt/opentelemetry_shell/venv/bin/python', '../actions/instrument/job/sdk_factory.py', os.path.join(directory, 'factory')],
            env=environment, stdout=output, stderr=errors,
        )
        try:
            for pid in (111, 222):
                commands = os.path.join(directory, f'commands-{pid}')
                response = os.path.join(directory, f'response-{pid}')
                with open(commands, 'w') as stream:
                    stream.write(f'RESOURCE_ATTRIBUTE int process.pid={pid}\nINIT\n'
                                 f'SPAN_START {response} - - auto INTERNAL factory-span-{pid}\n'
                                 'SPAN_END 0 auto\n')
                with open(os.path.join(directory, 'factory'), 'w') as stream:
                    stream.write(f'shell 1 {commands}\n')
                deadline = time.monotonic() + 30
                while True:
                    output.seek(0)
                    text = output.read()
                    try:
                        decoder = json.JSONDecoder()
                        spans = []
                        while text.strip():
                            span, end = decoder.raw_decode(text.lstrip())
                            text = text.lstrip()[end:]
                            spans.append(span)
                        span = next(item for item in spans if item['name'] == f'factory-span-{pid}')
                        break
                    except (ValueError, StopIteration):
                        if time.monotonic() >= deadline:
                            errors.seek(0)
                            raise AssertionError((text, errors.read()))
                        time.sleep(0.1)
                assert span['resource']['attributes']['process.pid'] == pid
                assert span['resource']['attributes']['cloud.resource_id'] == 'a,b=c/d e'
                assert 'host.cpu.count' not in span['resource']['attributes']
        finally:
            with open(os.path.join(directory, 'factory'), 'w') as stream:
                stream.write('EOF\n')
            factory.wait(timeout=30)

    result = subprocess.run(
        ['/opt/opentelemetry_shell/venv/bin/python', '/usr/share/opentelemetry_shell/sdk.py', 'shell', '1'],
        input=f'INIT\nDUMP_RESOURCE_ATTRIBUTES {attributes_path}\n', text=True, capture_output=True, check=True,
        env=os.environ.copy(),
    )
    assert result.stdout == ''
    with open(attributes_path) as attributes_file:
        assert attributes_file.read()
PY
