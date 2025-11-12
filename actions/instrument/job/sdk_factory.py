import os
from /usr/share/opentelemetry_shell/sdk.py import run

for line in sys.stdin:
  tokens = line.split(2, ' ');
  scope = tokens[0]
  version = tokens[1]
  pipe = tokens[2]
  pid = os.fork();
  if pid != 0:
    continue
  with open(pipe) as commands:
    run(scope, version, commands)
