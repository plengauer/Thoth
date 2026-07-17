"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * Copyright 2023 Google LLC
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.standardCloudRegion = exports.standardAvailabilityZone = exports.flexAvailabilityZoneAndRegion = exports.serviceInstance = exports.serviceVersion = exports.serviceName = exports.onAppEngine = exports.onAppEngineStandard = void 0;
/**
 * Implementation in this file copied from
 * https://github.com/GoogleCloudPlatform/opentelemetry-operations-go/blob/v1.8.0/detectors/gcp/app_engine.go
 */
const metadata = require("gcp-metadata");
const gce = require("./gce");
const faas = require("./faas");
const GAE_SERVICE_ENV = 'GAE_SERVICE';
const GAE_VERSION_ENV = 'GAE_VERSION';
const GAE_INSTANCE_ENV = 'GAE_INSTANCE';
const GAE_ENV = 'GAE_ENV';
const GAE_STANDARD = 'standard';
const ZONE_METADATA_ATTR = 'zone';
async function onAppEngineStandard() {
    return process.env[GAE_ENV] === GAE_STANDARD;
}
exports.onAppEngineStandard = onAppEngineStandard;
async function onAppEngine() {
    return process.env[GAE_SERVICE_ENV] !== undefined;
}
exports.onAppEngine = onAppEngine;
/**
 * The service name of the app engine service. Check that {@link onAppEngine()} is true before
 * calling this, or it may throw exceptions.
 */
async function serviceName() {
    return lookupEnv(GAE_SERVICE_ENV);
}
exports.serviceName = serviceName;
/**
 * The service version of the app engine service. Check that {@link onAppEngine()} is true
 * before calling this, or it may throw exceptions.
 */
async function serviceVersion() {
    return lookupEnv(GAE_VERSION_ENV);
}
exports.serviceVersion = serviceVersion;
/**
 * The service instance of the app engine service. Check that {@link onAppEngine()} is true
 * before calling this, or it may throw exceptions.
 */
async function serviceInstance() {
    return lookupEnv(GAE_INSTANCE_ENV);
}
exports.serviceInstance = serviceInstance;
/**
 * The zone and region in which this program is running. Check that {@link onAppEngine()} is
 * true before calling this, or it may throw exceptions.
 */
async function flexAvailabilityZoneAndRegion() {
    return await gce.availabilityZoneAndRegion();
}
exports.flexAvailabilityZoneAndRegion = flexAvailabilityZoneAndRegion;
/**
 * The zone the app engine service is running in. Check that {@link onAppEngineStandard()} is
 * true before calling this, or it may throw exceptions.
 */
async function standardAvailabilityZone() {
    const zone = await metadata.instance(ZONE_METADATA_ATTR);
    // zone is of the form "projects/233510669999/zones/us15"
    return zone.slice(zone.lastIndexOf('/') + 1);
}
exports.standardAvailabilityZone = standardAvailabilityZone;
/**
 * The region the app engine service is running in. Check that {@link onAppEngineStandard()} is
 * true before calling this, or it may throw exceptions.
 */
async function standardCloudRegion() {
    return await faas.faasCloudRegion();
}
exports.standardCloudRegion = standardCloudRegion;
function lookupEnv(key) {
    const val = process.env[key];
    if (val === undefined) {
        throw new Error(`Environment variable ${key} not found`);
    }
    return val;
}
//# sourceMappingURL=gae.js.map