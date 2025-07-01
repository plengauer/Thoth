import functools
import re
from importlib.metadata import version

from opentelemetry.sdk.resources import Resource, ResourceDetector
from opentelemetry.semconv.resource import ResourceAttributes

__version__ = version("opentelemetry_resourcedetector_docker")


class NotInDocker(Exception):
    pass


class DockerResourceDetector(ResourceDetector):
    """Detects OpenTelemetry Resource attributes for a container running within
    Docker, providing the `container.*` attributes if detected."""

    @functools.lru_cache(maxsize=1)
    def container_id(self) -> str:
        # cgroup v2 approach
        mount_pattern = r'.+/docker/containers/(?P<container_id>\w+)/.+'
        for line in self.mounts():
            if match := re.match(mount_pattern, line):
                return match.group('container_id')

        # cgroup v1 approach
        cgroup_pattern = r'\d+:[\w=]+:/docker(-[ce]e)?/(?P<container_id>\w+)'
        for line in self.cgroup_lines():
            if match := re.match(cgroup_pattern, line):
                return match.group('container_id')
        raise NotInDocker()

    @functools.lru_cache(maxsize=1)
    def mounts(self):
        with open('/proc/self/mountinfo', 'r', encoding='utf-8') as mounts:
            return list(mounts)

    @functools.lru_cache(maxsize=1)
    def cgroup_lines(self):
        with open('/proc/self/cgroup', 'r', encoding='utf-8') as cgroups:
            return list(cgroups)

    @functools.lru_cache(maxsize=1)
    def running_in_docker(self) -> bool:
        try:
            return bool(self.container_id())
        except FileNotFoundError:
            pass
        except NotInDocker:
            pass
        return False

    def detect(self) -> Resource:
        if not self.running_in_docker():
            return Resource.get_empty()

        return Resource(
            {
                ResourceAttributes.CONTAINER_RUNTIME: 'docker',
                ResourceAttributes.CONTAINER_ID: self.container_id(),
            }
        )
