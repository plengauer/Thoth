/*
 * Copyright The OpenTelemetry Authors
 * Copyright 2022 Google LLC
 * SPDX-License-Identifier: Apache-2.0
 */
import { context } from '@opentelemetry/api';
import { suppressTracing } from '@opentelemetry/core';
import { CLOUD_PLATFORM_VALUE_GCP_APP_ENGINE, CLOUD_PLATFORM_VALUE_GCP_CLOUD_FUNCTIONS, CLOUD_PLATFORM_VALUE_GCP_CLOUD_RUN, CLOUD_PLATFORM_VALUE_GCP_COMPUTE_ENGINE, CLOUD_PLATFORM_VALUE_GCP_KUBERNETES_ENGINE, CLOUD_PROVIDER_VALUE_GCP, ATTR_CLOUD_ACCOUNT_ID, ATTR_CLOUD_AVAILABILITY_ZONE, ATTR_CLOUD_PLATFORM, ATTR_CLOUD_PROVIDER, ATTR_CLOUD_REGION, ATTR_FAAS_INSTANCE, ATTR_FAAS_NAME, ATTR_FAAS_VERSION, ATTR_HOST_ID, ATTR_HOST_NAME, ATTR_HOST_TYPE, ATTR_K8S_CLUSTER_NAME, } from '../semconv';
import { emptyResource, resourceFromAttributes, } from '@opentelemetry/resources';
import * as metadata from 'gcp-metadata';
import * as faas from './faas';
import * as gae from './gae';
import * as gce from './gce';
import * as gke from './gke';
const ATTRIBUTE_NAMES = [
    ATTR_CLOUD_PLATFORM,
    ATTR_CLOUD_AVAILABILITY_ZONE,
    ATTR_CLOUD_REGION,
    ATTR_K8S_CLUSTER_NAME,
    ATTR_HOST_TYPE,
    ATTR_HOST_ID,
    ATTR_HOST_NAME,
    ATTR_CLOUD_PROVIDER,
    ATTR_CLOUD_ACCOUNT_ID,
    ATTR_FAAS_NAME,
    ATTR_FAAS_VERSION,
    ATTR_FAAS_INSTANCE,
];
async function detect() {
    if (!(await metadata.isAvailable())) {
        return emptyResource();
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
    return emptyResource();
}
async function gkeResource() {
    const [zoneOrRegion, k8sClusterName, hostId] = await Promise.all([
        gke.availabilityZoneOrRegion(),
        gke.clusterName(),
        gke.hostId(),
    ]);
    return await makeResource({
        [ATTR_CLOUD_PLATFORM]: CLOUD_PLATFORM_VALUE_GCP_KUBERNETES_ENGINE,
        [zoneOrRegion.type === 'zone'
            ? ATTR_CLOUD_AVAILABILITY_ZONE
            : ATTR_CLOUD_REGION]: zoneOrRegion.value,
        [ATTR_K8S_CLUSTER_NAME]: k8sClusterName,
        [ATTR_HOST_ID]: hostId,
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
        [ATTR_CLOUD_PLATFORM]: CLOUD_PLATFORM_VALUE_GCP_CLOUD_RUN,
        [ATTR_FAAS_NAME]: faasName,
        [ATTR_FAAS_VERSION]: faasVersion,
        [ATTR_FAAS_INSTANCE]: faasInstance,
        [ATTR_CLOUD_REGION]: faasCloudRegion,
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
        [ATTR_CLOUD_PLATFORM]: CLOUD_PLATFORM_VALUE_GCP_CLOUD_FUNCTIONS,
        [ATTR_FAAS_NAME]: faasName,
        [ATTR_FAAS_VERSION]: faasVersion,
        [ATTR_FAAS_INSTANCE]: faasInstance,
        [ATTR_CLOUD_REGION]: faasCloudRegion,
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
        [ATTR_CLOUD_PLATFORM]: CLOUD_PLATFORM_VALUE_GCP_APP_ENGINE,
        [ATTR_FAAS_NAME]: faasName,
        [ATTR_FAAS_VERSION]: faasVersion,
        [ATTR_FAAS_INSTANCE]: faasInstance,
        [ATTR_CLOUD_AVAILABILITY_ZONE]: zone,
        [ATTR_CLOUD_REGION]: region,
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
        [ATTR_CLOUD_PLATFORM]: CLOUD_PLATFORM_VALUE_GCP_COMPUTE_ENGINE,
        [ATTR_CLOUD_AVAILABILITY_ZONE]: zoneAndRegion.zone,
        [ATTR_CLOUD_REGION]: zoneAndRegion.region,
        [ATTR_HOST_TYPE]: hostType,
        [ATTR_HOST_ID]: hostId,
        [ATTR_HOST_NAME]: hostName,
    });
}
async function makeResource(attrs) {
    const project = await metadata.project('project-id');
    return resourceFromAttributes({
        [ATTR_CLOUD_PROVIDER]: CLOUD_PROVIDER_VALUE_GCP,
        [ATTR_CLOUD_ACCOUNT_ID]: project,
        ...attrs,
    });
}
/**
 * Google Cloud resource detector which populates attributes based on the environment this
 * process is running in. If not on GCP, returns an empty resource.
 */
export class GcpDetector {
    async _asyncAttributes() {
        const resource = await context.with(suppressTracing(context.active()), detect);
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
export const gcpDetector = new GcpDetector();
//# sourceMappingURL=GcpDetector.js.map