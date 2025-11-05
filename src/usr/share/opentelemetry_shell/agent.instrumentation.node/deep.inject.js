const process = require('process');
const child_process = require('child_process');
const _spawn = child_process.spawn;
const _spawnSync = child_process.spawnSync;
const _exec = child_process.exec;
const _execSync = child_process.execSync;
const _execFile = child_process.execFile;
const _execFileSync = child_process.execFileSync;

if (process.platform != 'linux') return;

child_process.spawn = function(command, args, options) {
  return otel_spawn(command, args, options, _spawn);
}

child_process.spawnSync = function(command, args, options) {
  return otel_spawn(command, args, options, _spawnSync);
}

function otel_spawn(command, args, options, original) {
  if (args && !options && !Array.isArray(args)) {
    options = args;
    args = [];
  }
  if (options && options.stdio && Array.isArray(options.stdio) && options.stdio.length > 3) return _spawn(command, args, options);
  options = options ? options : {};
  options.env = options.env ? options.env : { ... process.env };
  if (command.includes('/')) command = '_otel_inject ' + command;
  shell_propagator_inject(options.env);
  options.env['OTEL_SHELL_AUTO_INSTRUMENTATION_HINT'] = command;
  if (options.shell) {
    if (typeof options.shell == 'boolean') options.shell = '/bin/sh';
    options.env['OTEL_SHELL_COMMANDLINE_OVERRIDE'] = options.shell + ' -c ' + command + ' ' + args.join(' ');
    options.env['OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE'] = process.pid;
    options.env['OTEL_SHELL_AUTO_INJECTED'] = 'FALSE'
    return original(options.shell, [ '-c', '. otel.sh\n' + command + ' "$@"', options.shell ].concat(args ? args : []), { ... options, shell: false });
  } else {
    return original('/bin/sh', [ '-c', '. otel.sh\n' + command + ' "$@"', 'node' ].concat(args ? args : []), options);
  }
}

child_process.exec = function(command, options, callback) {
  return otel_exec(command, options, callback, _exec);
}

child_process.execSync = function(command, options) {
  return otel_exec(command, options, undefined, _execSync);
}

function otel_exec(command, options, callback, original) {
  if (options && !callback && typeof options == 'function') {
    callback = options;
    options = {};
  }
  if (options && options.stdio && Array.isArray(options.stdio) && options.stdio.length > 3) return _exec(command, options, callback);
  if (command.includes('/')) command = '_otel_inject ' + command;
  options = options ? options : {};
  options.env = options.env ? options.env : { ... process.env };
  shell_propagator_inject(options.env);
  options.env['OTEL_SHELL_AUTO_INSTRUMENTATION_HINT'] = command;
  options.env['OTEL_SHELL_COMMANDLINE_OVERRIDE'] = (options.shell ? options.shell : '/bin/sh') + ' -c ' + command;
  options.env['OTEL_SHELL_COMMANDLINE_OVERRIDE_SIGNATURE'] = process.pid;
  options.env['OTEL_SHELL_AUTO_INJECTED'] = 'FALSE'
  return original('. otel.sh\n' + command, options, callback);
}

/*
child_process.execFile = function(file, args, options, callback) {
  options = options ? options : {};
  options.env = options.env ? options.env : { ... process.env };
  return _execFile('/bin/sh', [ '-c', '. otel.sh\n' + file + ' "$@"', 'node' ].concat(args ? args : []), options, callback);
}
*/

function shell_propagator_inject(env) {
  try {
    let opentelemetry_api = require('@opentelemetry/api');
    let opentelemetry_sdk = require('@opentelemetry/sdk-node');
    let carrier = {};
    new opentelemetry_sdk.core.W3CTraceContextPropagator().inject(opentelemetry_api.context.active(), carrier, opentelemetry_api.defaultTextMapSetter);
    env.TRACEPARENT = carrier.traceparent ? carrier.traceparent : (process.env.TRACEPARENT ? process.env.TRACEPARENT : '');
    env.TRACESTATE = carrier.tracestate ? carrier.tracestate : (process.env.TRACESTATE ? process.env.TRACESTATE : '');
  } catch (err) {
    if (err.code != 'MODULE_NOT_FOUND') {
      throw err;
    }
    env.TRACEPARENT = process.env.TRACEPARENT ? process.env.TRACEPARENT : '';
    env.TRACESTATE = process.env.TRACESTATE ? process.env.TRACESTATE : '';
  }
  Object.entries(process.env).filter(([key]) => key.startsWith('OTEL_')).forEach(([key, value]) => env[key] = value);
}

