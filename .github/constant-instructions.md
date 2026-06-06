*) the project is hard to build. look at the build.yml and recreate the steps to build a deb. if the goal of a task does not involve deep injection into other techs like node/python/java then one needs only to build the deb package without the additional dependencies.
*) instrumentation is done via aliases of shell commands, so all internal code must be prefixed with a backslash to avoid aliasing.
*) all shell code must be compliant to ash, dash, bash and busybox.
*) all shell code should use lower case variable names with underscores.
*) do not generate simulated tests where code is copied and tested. if one cannot re-use the real code, prefer not tests at all.
*) when generating shell code, use as much piping as possible but keep dependencies to a minimum.
*) when reviewing code and looking at instrumentation of workflows, do not comment when missing secrets are otel secrets. they do need to be redacted.
