"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.HapiLifecycleMethodNames = exports.HapiLayerType = exports.handlerPatched = exports.HapiComponentName = void 0;
exports.HapiComponentName = '@hapi/hapi';
/**
 * This symbol is used to mark a Hapi route handler or server extension handler as
 * already patched, since its possible to use these handlers multiple times
 * i.e. when allowing multiple versions of one plugin, or when registering a plugin
 * multiple times on different servers.
 */
exports.handlerPatched = Symbol('hapi-handler-patched');
exports.HapiLayerType = {
    ROUTER: 'router',
    PLUGIN: 'plugin',
    EXT: 'server.ext',
};
exports.HapiLifecycleMethodNames = new Set([
    'onPreAuth',
    'onCredentials',
    'onPostAuth',
    'onPreHandler',
    'onPostHandler',
    'onPreResponse',
    'onRequest',
]);
//# sourceMappingURL=internal-types.js.map