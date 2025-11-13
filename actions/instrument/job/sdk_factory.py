import sys
import os
import signal

import importlib.util
spec = importlib.util.spec_from_file_location("sdk", "/usr/share/opentelemetry_shell/sdk.py")
sdk = importlib.util.module_from_spec(spec)
sys.modules["sdk"] = sdk
spec.loader.exec_module(sdk)

signal.signal(signal.SIGCHLD, signal.SIG_IGN)

while True:
  with open(sys.argv[1]) as pipe:
    try:
      for line in pipe:
        line = line.strip()
        if line == "EOF":
          sys.exit()
        tokens = line.split(" ", 2)
        scope = tokens[0]
        version = tokens[1]
        pipe = tokens[2]
        pid = os.fork()
        if pid != 0:
          continue
        sys.stdin.close()
        with open(pipe) as commands:
          sdk.run(scope, version, commands)
    except:
      pass
