const opentelemetry_api = require('@opentelemetry/api');
const opentelemetry_sdk = require('@opentelemetry/sdk-node');
const opentelemetry_auto_instrumentations = require('@opentelemetry/auto-instrumentations-node');
const opentelemetry_resources = require('@opentelemetry/resources');
const opentelemetry_resources_git = require('opentelemetry-resource-detector-git');
const opentelemetry_resources_github = require('@opentelemetry/resource-detector-github');
const opentelemetry_resources_container = require('@opentelemetry/resource-detector-container');
const opentelemetry_resources_aws = require('@opentelemetry/resource-detector-aws');
const opentelemetry_resources_azure = require('@opentelemetry/resource-detector-azure');
const opentelemetry_resources_gcp = require('@opentelemetry/resource-detector-gcp');
const opentelemetry_resources_alibaba_cloud = require('@opentelemetry/resource-detector-alibaba-cloud');
const context_async_hooks = require("@opentelemetry/context-async-hooks");
const semver = require("semver");

// lets wrap the default context manager with our custom one that provides the context based on the parent env var instead of the default root context
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
const MY_ROOT_CONTEXT = new opentelemetry_sdk.core.W3CTraceContextPropagator().extract(opentelemetry_api.ROOT_CONTEXT, { traceparent: process.env.TRACEPARENT, tracestate: process.env.TRACESTATE }, opentelemetry_api.defaultTextMapGetter);
const context_manager = new CustomRootContextManager(semver.gte(process.version, '14.8.0') ? new context_async_hooks.AsyncLocalStorageContextManager() : new context_async_hooks.AsyncHooksContextManager(), MY_ROOT_CONTEXT);

// node.js terminates when event loop is empty and flushing the SDK (below) is unfortunately async.
// creating a simple span processor manually is a pain because all the exporter creation and configuration logic is not publicly accessible.
// so lets give the BatchSpanProcessor an identity crisis and demote him to a SimpleSpanProcessor that will start flushing synchronously on every span getting queued
process.env.OTEL_BSP_MAX_EXPORT_BATCH_SIZE=1

const sdk = new opentelemetry_sdk.NodeSDK({
  contextManager: context_manager.enable(),
  instrumentations: [ opentelemetry_auto_instrumentations.getNodeAutoInstrumentations() ],
  resourceDetectors: [
    opentelemetry_resources_alibaba_cloud.alibabaCloudEcsDetector,
    opentelemetry_resources_azure.azureAppServiceDetector,
    // opentelemetry_resources_gcp.gcpDetector, // TODO makes noisy spans!
    opentelemetry_resources_aws.awsBeanstalkDetector,
    opentelemetry_resources_aws.awsEc2Detector,
    opentelemetry_resources_aws.awsEcsDetector,
    opentelemetry_resources_aws.awsEksDetector,
    // TODO k8s detector
    opentelemetry_resources_container.containerDetector,
    opentelemetry_resources_git.gitSyncDetector,
    opentelemetry_resources_github.gitHubDetector,
    opentelemetry_resources.processDetector,
    opentelemetry_resources.envDetector
  ],
});

process.on('exit', () => sdk.shutdown());
process.on('SIGINT', () => sdk.shutdown());
process.on('SIGQUIT', () => sdk.shutdown())

sdk.start();
