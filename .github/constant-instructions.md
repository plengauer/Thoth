*) use the build skill in .github/skills/build-packages.md. derive build instructions from .github/workflows/build.yml and its needs graph. keep builds minimal to task scope (for example skip node/python/java/http rebuilds when unaffected).
*) instrumentation is done via aliases of shell commands, so all internal code must be prefixed with a backslash to avoid aliasing.
*) all shell code must be compliant to ash, dash, bash and busybox.
*) all shell code sould use lower case variable names with underscores.
*) do not generate simulated tests where code is copied and tested. if one cannot re-use the real code, prefer not tests at all.
*) when generating shell code, use as much piping as possible but keep dependencies to a minimum.
*) when reviewing code and looking at instrumentition of workflows, do not comment when missing secrets are otel secrets. they do need to be redacted.
