import sys
import os

import importlib.util
spec = importlib.util.spec_from_file_location("sdk", "/usr/share/opentelemetry_shell/sdk.py")
helpers = importlib.util.module_from_spec(spec)
sys.modules["sdk"] = helpers
spec.loader.exec_module(helpers)

import sdk

for line in sys.stdin:
  line = line.strip()
  tokens = line.split(" ", 2)
  scope = tokens[0]
  version = tokens[1]
  pipe = tokens[2]
  pid = os.fork()
  if pid != 0:
    continue
  with open(pipe) as commands:
    sdk.run(scope, version, commands)
