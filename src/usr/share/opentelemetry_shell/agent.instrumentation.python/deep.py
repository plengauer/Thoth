import os
# required to re-inject the environment into child processes
import subprocess  # nosec B404

for _otel_key in ("OTEL_SHELL_COMMANDLINE_OVERRIDE", "OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE", "OTEL_SHELL_AUTO_INJECTED"):
    os.environ.pop(_otel_key, None)


def inject_env_minimal(env, file, args):
    env.update({k: v for k, v in os.environ.items() if k.startswith("OTEL_")})
    env["OTEL_SHELL_AUTO_INSTRUMENTATION_HINT"] = file
    env["OTEL_SHELL_COMMANDLINE_OVERRIDE"] = " ".join(args)
    env["OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE"] = str(os.getpid())
    return env


try:
    from opentelemetry.baggage.propagation import W3CBaggagePropagator
    from opentelemetry.context import attach
    from opentelemetry.propagators.composite import CompositePropagator
    from opentelemetry.trace.propagation.tracecontext import (
        TraceContextTextMapPropagator,
    )

    def _otel_b3_propagator():
        # the b3 propagator is a separate package,
        # the environment of the instrumented process may not have it
        try:
            from opentelemetry.propagators.b3 import B3SingleFormat

            return B3SingleFormat()
        except ModuleNotFoundError:
            return None

    _otel_propagator_names = (
        os.getenv("OTEL_PROPAGATORS") or "tracecontext,baggage"
    ).split(",")
    names = list(
        {name.strip().lower(): None for name in _otel_propagator_names if name.strip()}
    )
    if not {"tracecontext", "b3"}.intersection(names) and set(names) - {
        "none",
        "baggage",
    }:
        names.append("tracecontext")
    propagators = {
        "tracecontext": TraceContextTextMapPropagator,
        "b3": _otel_b3_propagator,
        "baggage": W3CBaggagePropagator,
    }
    propagate = CompositePropagator(
        [
            propagator
            for propagator in (
                propagators[name]() for name in names if name in propagators
            )
            if propagator is not None
        ]
    )

    carrier = {
        key.lower(): os.environ[key]
        for key in ("TRACEPARENT", "TRACESTATE", "B3", "BAGGAGE")
        if os.environ.get(key)
    }
    if carrier:
        attach(propagate.extract(carrier))

    def inject_env(env, file, args):
        carrier = {}
        propagate.inject(carrier)
        for key in ("traceparent", "tracestate", "b3", "baggage"):
            if key in carrier:
                env[key.upper()] = carrier[key]
        return inject_env_minimal(env, file, args)

except ModuleNotFoundError:

    def inject_env(env, file, args):
        return inject_env_minimal(env, file, args)


def inject_arguments(file, args, is_file=True):
    try:
        file = file.decode()
    except (UnicodeDecodeError, AttributeError):
        pass
    arg_zero = None
    if is_file:
        if "/" not in file:
            for path in os.environ["PATH"].split(":"):
                file_candidate = path + "/" + file
                if (
                    not os.path.exists(file_candidate)
                    or not os.path.isfile(file_candidate)
                    or not os.access(file_candidate, os.X_OK)
                ):
                    continue
                file = file_candidate
                break
        if (
            not os.path.exists(file)
            or not os.path.isfile(file)
            or not os.access(file, os.X_OK)
        ):
            raise FileNotFoundError(
                file
            )  # python will just trial and error all possible paths if the 'p' variants of exec are used
        arg_zero = file
        file = "_otel_inject '" + file + "'"
    else:
        arg_zero = "python"
    return ["-c", ". otel.sh\n" + file + ' "$@"', arg_zero] + args


def inject_file(file):
    return "/bin/sh"


original_os_execve = os.execve
original_subprocess_Popen___init__ = subprocess.Popen.__init__


def observed_os_execv(file, args):
    if type(args) is tuple:
        args = list(args)
    env = inject_env(os.environ.copy(), file, args)
    args = ["sh"] + inject_arguments(file, args[1:])
    file = inject_file(file)
    return original_os_execve(file, args, env)


def observed_os_execve(file, args, env):
    if type(args) is tuple:
        args = list(args)
    env = inject_env(env, file, args)
    args = ["sh"] + inject_arguments(file, args[1:])
    file = inject_file(file)
    return original_os_execve(file, args, env)


def observed_subprocess_Popen___init__(self, *args, **kwargs):
    args = list(args)
    if len(args) > 0 and type(args[0]) is list:
        args = args[0]
    if len(args) > 0 and type(args[0]) is tuple:
        args = list(args[0])
    kwargs["env"] = kwargs.get("env", None)
    if not kwargs["env"]:
        kwargs["env"] = os.environ.copy()
    kwargs["env"] = inject_env(kwargs["env"], kwargs.get("executable", args[0]), args)
    args = [inject_file(kwargs.get("executable", args[0]))] + inject_arguments(
        kwargs.get("executable", args[0]), args[1:], not kwargs.get("shell", False)
    )
    if kwargs.get("executable"):
        kwargs["executable"] = inject_file(kwargs["executable"])
    if kwargs.get("shell", False):
        kwargs["env"]["OTEL_SHELL_AUTO_INJECTED"] = "FALSE"
        kwargs["shell"] = False
    return original_subprocess_Popen___init__(self, args, **kwargs)


os.execv = observed_os_execv
os.execve = observed_os_execve
setattr(subprocess.Popen, '__init__', observed_subprocess_Popen___init__)
