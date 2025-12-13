const opentelemetry_api = require('@opentelemetry/api');
const opentelemetry_sdk = require('@opentelemetry/sdk-node');
const context_async_hooks = require("@opentelemetry/context-async-hooks");
const semver = require("semver");

// node.js terminates when event loop is empty and flushing the SDK (below) is unfortunately async.
// creating a simple span processor manually is a pain because all the exporter creation and configuration logic is not publicly accessible.
// so lets give the BatchSpanProcessor an identity crisis and demote him to a SimpleSpanProcessor that will start flushing synchronously on every span getting queued
process.env.OTEL_BSP_MAX_EXPORT_BATCH_SIZE=1

class CustomRootContextManager {
  inner;
  custom_context;

  constructor(inner, custom_context) {
    this.inner = inner;
    this.custom_context = custom_context;
  }

  enable() { this.inner.enable(); return this; }
  disable() { this.inner.disable(); return this; }
  bind(...args) { return this.inner.bind(...args); }
  with(...args) { return this.inner.with(...args); }

  active() {
    let context = this.inner.active();
    if (opentelemetry_api.ROOT_CONTEXT == context || !opentelemetry_api.trace.getSpan(context)) {
      context = this.custom_context;
    }
    return context;
  }
}

function wrapAndSetGlobalContextManager(setGlobalContextManager, context_manager) {
  const MY_ROOT_CONTEXT = new opentelemetry_sdk.core.W3CTraceContextPropagator().extract(opentelemetry_api.ROOT_CONTEXT, { traceparent: process.env.TRACEPARENT, tracestate: process.env.TRACESTATE }, opentelemetry_api.defaultTextMapGetter);
  return setGlobalContextManager(new CustomRootContextManager(context_manager, MY_ROOT_CONTEXT));
}

const _setGlobalContextManager = opentelemetry_api.context.setGlobalContextManager;
opentelemetry_api.context.setGlobalContextManager = function(context_manager) { return wrapAndSetGlobalContextManager(_setGlobalContextManager, context_manager); };

const _module = require('module');
const __load = _module._load;
_module._load = function(request, parent, isMain) {
  const exports = __load.apply(this, arguments);
  if (request === '@opentelemetry/api') {
    const _setGlobalContextManager = exports.context.setGlobalContextManager;
    exports.context.setGlobalContextManager = function(context_manager) { return wrapAndSetGlobalContextManager(_setGlobalContextManager, context_manager); };
  }
  return exports;
};
