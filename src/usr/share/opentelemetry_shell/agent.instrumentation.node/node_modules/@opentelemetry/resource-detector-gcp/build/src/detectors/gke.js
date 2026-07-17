"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * Copyright 2022 Google LLC
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.availabilityZoneOrRegion = exports.clusterName = exports.hostId = exports.onGke = void 0;
/**
 * Implementation in this file copied from
 * https://github.com/GoogleCloudPlatform/opentelemetry-operations-go/blob/v1.8.0/detectors/gcp/gke.go
 */
const metadata = require("gcp-metadata");
const gce = require("./gce");
const KUBERNETES_SERVICE_HOST_ENV = 'KUBERNETES_SERVICE_HOST';
const CLUSTER_NAME_METADATA_ATTR = 'attributes/cluster-name';
const CLUSTER_LOCATION_METADATA_ATTR = 'attributes/cluster-location';
async function onGke() {
    return process.env[KUBERNETES_SERVICE_HOST_ENV] !== undefined;
}
exports.onGke = onGke;
/**
 * The instance ID of the instance on which this program is running. Check that {@link onGke()}
 * is true before calling this, or it may throw exceptions.
 */
async function hostId() {
    return await gce.hostId();
}
exports.hostId = hostId;
/**
 * The name of the GKE cluster in which this program is running. Check that {@link onGke()} is
 * true before calling this, or it may throw exceptions.
 */
async function clusterName() {
    return metadata.instance(CLUSTER_NAME_METADATA_ATTR);
}
exports.clusterName = clusterName;
/**
 * The location of the cluster and whether the cluster is zonal or regional. Check that {@link
 * onGke()} is true before calling this, or it may throw exceptions.
 */
async function availabilityZoneOrRegion() {
    const clusterLocation = await metadata.instance(CLUSTER_LOCATION_METADATA_ATTR);
    switch (countChar(clusterLocation, '-')) {
        case 1:
            return { type: 'region', value: clusterLocation };
        case 2:
            return { type: 'zone', value: clusterLocation };
        default:
            throw new Error(`unrecognized format for cluster location: ${clusterLocation}`);
    }
}
exports.availabilityZoneOrRegion = availabilityZoneOrRegion;
function countChar(s, char) {
    let count = 0;
    for (let i = 0; i < s.length; i++) {
        if (s[i] === char) {
            count += 1;
        }
    }
    return count;
}
//# sourceMappingURL=gke.js.map