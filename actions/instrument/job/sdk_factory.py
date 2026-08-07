import sys
import os

import importlib.util
spec = importlib.util.spec_from_file_location("sdk", "/usr/share/opentelemetry_shell/sdk.py")
if spec is None or spec.loader is None:
  raise ImportError("Unable to load /usr/share/opentelemetry_shell/sdk.py")
sdk = importlib.util.module_from_spec(spec)
sys.modules["sdk"] = sdk
spec.loader.exec_module(sdk)

while True:
  with open(sys.argv[1]) as input_pipe:
    for line in input_pipe:
      line = line.strip()
      if line == "EOF":
        sys.exit()
      pid = os.fork()
      if pid != 0:
        continue
      pid = os.fork()
      if pid != 0:
        sys.exit(0)
      tokens = line.split(" ", 2)
      scope = tokens[0]
      version = tokens[1]
      command_pipe = tokens[2]
      with open(command_pipe) as commands:
        sdk.run(scope, version, commands)
        sys.exit(0)
