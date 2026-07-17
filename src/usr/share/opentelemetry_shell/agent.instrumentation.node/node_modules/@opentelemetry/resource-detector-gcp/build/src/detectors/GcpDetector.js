"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * Copyright 2022 Google LLC
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.gcpDetector = exports.GcpDetector = void 0;
const api_1 = require("@opentelemetry/api");
const core_1 = require("@opentelemetry/core");
const semconv_1 = require("../semconv");
const resources_1 = require("@opentelemetry/resources");
const metadata = require("gcp-metadata");
const faas = require("./faas");
const gae = require("./gae");
const gce = require("./gce");
const gke = require("./gke");
const ATTRIBUTE_NAMES = [
    semconv_1.ATTR_CLOUD_PLATFORM,
    semconv_1.ATTR_CLOUD_AVAILABILITY_ZONE,
    semconv_1.ATTR_CLOUD_REGION,
    semconv_1.ATTR_K8S_CLUSTER_NAME,
    semconv_1.ATTR_HOST_TYPE,
    semconv_1.ATTR_HOST_ID,
    semconv_1.ATTR_HOST_NAME,
    semconv_1.ATTR_CLOUD_PROVIDER,
    semconv_1.ATTR_CLOUD_ACCOUNT_ID,
    semconv_1.ATTR_FAAS_NAME,
    semconv_1.ATTR_FAAS_VERSION,
    semconv_1.ATTR_FAAS_INSTANCE,
];
async function detect() {
    if (!(await metadata.isAvailable())) {
        return (0, resources_1.emptyResource)();
    }
    // Note the order of these if checks is significant with more specific resources coming
    // first. E.g. Cloud Functions gen2 are executed in Cloud Run so it must be checked first.
    if (await gke.onGke()) {
        return await gkeResource();
    }
    else if (await faas.onCloudFunctions()) {
        return await cloudFunctionsResource();
    }
    else if (await faas.onCloudRun()) {
        return await cloudRunResource();
    }
    else if (await gae.onAppEngine()) {
        return await gaeResource();
    }
    else if (await gce.onGce()) {
        return await gceResource();
    }
    return (0, resources_1.emptyResource)();
}
async function gkeResource() {
    const [zoneOrRegion, k8sClusterName, hostId] = await Promise.all([
        gke.availabilityZoneOrRegion(),
        gke.clusterName(),
        gke.hostId(),
    ]);
    return await makeResource({
        [semconv_1.ATTR_CLOUD_PLATFORM]: semconv_1.CLOUD_PLATFORM_VALUE_GCP_KUBERNETES_ENGINE,
        [zoneOrRegion.type === 'zone'
            ? semconv_1.ATTR_CLOUD_AVAILABILITY_ZONE
            : semconv_1.ATTR_CLOUD_REGION]: zoneOrRegion.value,
        [semconv_1.ATTR_K8S_CLUSTER_NAME]: k8sClusterName,
        [semconv_1.ATTR_HOST_ID]: hostId,
    });
}
async function cloudRunResource() {
    const [faasName, faasVersion, faasInstance, faasCloudRegion] = await Promise.all([
        faas.faasName(),
        faas.faasVersion(),
        faas.faasInstance(),
        faas.faasCloudRegion(),
    ]);
    return await makeResource({
        [semconv_1.ATTR_CLOUD_PLATFORM]: semconv_1.CLOUD_PLATFORM_VALUE_GCP_CLOUD_RUN,
        [semconv_1.ATTR_FAAS_NAME]: faasName,
        [semconv_1.ATTR_FAAS_VERSION]: faasVersion,
        [semconv_1.ATTR_FAAS_INSTANCE]: faasInstance,
        [semconv_1.ATTR_CLOUD_REGION]: faasCloudRegion,
    });
}
async function cloudFunctionsResource() {
    const [faasName, faasVersion, faasInstance, faasCloudRegion] = await Promise.all([
        faas.faasName(),
        faas.faasVersion(),
        faas.faasInstance(),
        faas.faasCloudRegion(),
    ]);
    return await makeResource({
        [semconv_1.ATTR_CLOUD_PLATFORM]: semconv_1.CLOUD_PLATFORM_VALUE_GCP_CLOUD_FUNCTIONS,
        [semconv_1.ATTR_FAAS_NAME]: faasName,
        [semconv_1.ATTR_FAAS_VERSION]: faasVersion,
        [semconv_1.ATTR_FAAS_INSTANCE]: faasInstance,
        [semconv_1.ATTR_CLOUD_REGION]: faasCloudRegion,
    });
}
async function gaeResource() {
    let zone, region;
    if (await gae.onAppEngineStandard()) {
        [zone, region] = await Promise.all([
            gae.standardAvailabilityZone(),
            gae.standardCloudRegion(),
        ]);
    }
    else {
        ({ zone, region } = await gce.availabilityZoneAndRegion());
    }
    const [faasName, faasVersion, faasInstance] = await Promise.all([
        gae.serviceName(),
        gae.serviceVersion(),
        gae.serviceInstance(),
    ]);
    return await makeResource({
        [semconv_1.ATTR_CLOUD_PLATFORM]: semconv_1.CLOUD_PLATFORM_VALUE_GCP_APP_ENGINE,
        [semconv_1.ATTR_FAAS_NAME]: faasName,
        [semconv_1.ATTR_FAAS_VERSION]: faasVersion,
        [semconv_1.ATTR_FAAS_INSTANCE]: faasInstance,
        [semconv_1.ATTR_CLOUD_AVAILABILITY_ZONE]: zone,
        [semconv_1.ATTR_CLOUD_REGION]: region,
    });
}
async function gceResource() {
    const [zoneAndRegion, hostType, hostId, hostName] = await Promise.all([
        gce.availabilityZoneAndRegion(),
        gce.hostType(),
        gce.hostId(),
        gce.hostName(),
    ]);
    return await makeResource({
        [semconv_1.ATTR_CLOUD_PLATFORM]: semconv_1.CLOUD_PLATFORM_VALUE_GCP_COMPUTE_ENGINE,
        [semconv_1.ATTR_CLOUD_AVAILABILITY_ZONE]: zoneAndRegion.zone,
        [semconv_1.ATTR_CLOUD_REGION]: zoneAndRegion.region,
        [semconv_1.ATTR_HOST_TYPE]: hostType,
        [semconv_1.ATTR_HOST_ID]: hostId,
        [semconv_1.ATTR_HOST_NAME]: hostName,
    });
}
async function makeResource(attrs) {
    const project = await metadata.project('project-id');
    return (0, resources_1.resourceFromAttributes)({
        [semconv_1.ATTR_CLOUD_PROVIDER]: semconv_1.CLOUD_PROVIDER_VALUE_GCP,
        [semconv_1.ATTR_CLOUD_ACCOUNT_ID]: project,
        ...attrs,
    });
}
/**
 * Google Cloud resource detector which populates attributes based on the environment this
 * process is running in. If not on GCP, returns an empty resource.
 */
class GcpDetector {
    async _asyncAttributes() {
        const resource = await api_1.context.with((0, core_1.suppressTracing)(api_1.context.active()), detect);
        return resource.attributes;
    }
    detect() {
        const asyncAttributes = this._asyncAttributes();
        const attributes = {};
        ATTRIBUTE_NAMES.forEach(name => {
            // Each resource attribute is determined asynchronously in _gatherData().
            attributes[name] = asyncAttributes.then(data => data[name]);
        });
        return { attributes };
    }
}
exports.GcpDetector = GcpDetector;
exports.gcpDetector = new GcpDetector();
//# sourceMappingURL=GcpDetector.js.map