import functools
import os
import re
from importlib.metadata import version
from typing import Dict, Tuple, Union

from opentelemetry.sdk.resources import Resource, ResourceDetector
from opentelemetry.semconv.resource import ResourceAttributes

__version__ = version("opentelemetry_resourcedetector_kubernetes")

Attributes = Dict[str, Union[str, bool, int, float]]


class NotInKubernetes(Exception):
    pass


class KubernetesResourceDetector(ResourceDetector):
    """Detects OpenTelemetry Resource attributes for a Kubernetes Pod, providing
    minimal the `container.runtime`, `container.id`, and `k8s.pod.uid` attributes"""

    cgroup_pattern = re.compile(
        r'\d+:[\w=]+:/kubepods/.+'
        r'/pod(?P<pod_uid>[a-f0-9\-]+)'
        r'/(?P<container_id>[a-f0-9\-]+)'
    )
    cgroup_file = '/proc/self/cgroup'

    @functools.lru_cache(maxsize=1)
    def _pod_and_container_ids(self) -> Tuple[str, str]:
        for line in self.cgroup_lines():
            if match := self.cgroup_pattern.match(line):
                return match.group('pod_uid'), match.group('container_id')
        raise NotInKubernetes()

    def pod_uid(self) -> str:
        return self._pod_and_container_ids()[0]

    def container_id(self) -> str:
        return self._pod_and_container_ids()[1]

    @functools.lru_cache(maxsize=1)
    def cgroup_lines(self):
        with open(self.cgroup_file, 'r', encoding='utf-8') as cgroups:
            return list(cgroups)

    @functools.lru_cache(maxsize=1)
    def running_in_kubernetes(self) -> bool:
        try:
            return bool(self.pod_uid() and self.container_id())
        except FileNotFoundError:
            pass
        except NotInKubernetes:
            pass
        return False

    def detect(self) -> Resource:
        if not self.running_in_kubernetes():
            return Resource.get_empty()

        attributes: Attributes = {
            ResourceAttributes.CONTAINER_RUNTIME: 'kubernetes',
            ResourceAttributes.K8S_POD_UID: self.pod_uid(),
            ResourceAttributes.CONTAINER_ID: self.container_id(),
        }
        return Resource.create(attributes)


class KubernetesDownwardAPIEnvironmentResourceDetector(KubernetesResourceDetector):
    DETECTABLE = {
        constant: getattr(ResourceAttributes, constant)
        for constant in dir(ResourceAttributes)
        if constant.startswith(('K8S_', 'CONTAINER_'))
    }

    # https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/
    def __init__(self, prefix='OTEL_RD', **kwargs):
        super().__init__(**kwargs)
        self.prefix = prefix + ('_' if not prefix.endswith('_') else '')

    def detect(self) -> Resource:
        resource = super().detect()
        if resource == Resource.get_empty():
            return resource

        eligible_environment_variables: Attributes = {
            key.replace(self.prefix, '', 1): value
            for key, value in os.environ.items()
            if key.startswith(self.prefix)
        }
        attributes: Attributes = {
            self.DETECTABLE[key]: value
            for key, value in eligible_environment_variables.items()
            if key in self.DETECTABLE
        }
        return resource.merge(Resource.create(attributes))


class KubernetesDownwardAPIVolumeResourceDetector(KubernetesResourceDetector):
    # https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/
    DETECTABLE = {
        getattr(ResourceAttributes, constant)
        for constant in dir(ResourceAttributes)
        if constant.startswith(('K8S_', 'CONTAINER_'))
    }

    def __init__(self, directory='/etc/otelrd', **kwargs):
        super().__init__(**kwargs)
        self.directory = directory

    def detect(self) -> Resource:
        resource = super().detect()
        if resource == Resource.get_empty():
            return resource

        if not os.path.exists(self.directory):
            return resource

        def readfile(filename):
            full_path = os.path.join(self.directory, filename)
            with open(full_path, 'r', encoding='utf-8') as f:
                return f.read()

        attributes: Attributes = {
            filename: readfile(filename)
            for filename in os.listdir(self.directory)
            if filename in self.DETECTABLE
        }

        return resource.merge(Resource.create(attributes))
