"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateRoute = exports.replaceCurrentStackRoute = exports.addNewStackLayer = void 0;
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
const api_1 = require("@opentelemetry/api");
const internal_types_1 = require("./internal-types");
const addNewStackLayer = (request) => {
    if (Array.isArray(request[internal_types_1._LAYERS_STORE_PROPERTY]) === false) {
        Object.defineProperty(request, internal_types_1._LAYERS_STORE_PROPERTY, {
            enumerable: false,
            value: [],
        });
    }
    request[internal_types_1._LAYERS_STORE_PROPERTY].push('/');
    const stackLength = request[internal_types_1._LAYERS_STORE_PROPERTY].length;
    return () => {
        if (stackLength === request[internal_types_1._LAYERS_STORE_PROPERTY].length) {
            request[internal_types_1._LAYERS_STORE_PROPERTY].pop();
        }
        else {
            api_1.diag.warn('Connect: Trying to pop the stack multiple time');
        }
    };
};
exports.addNewStackLayer = addNewStackLayer;
const replaceCurrentStackRoute = (request, newRoute) => {
    if (newRoute) {
        request[internal_types_1._LAYERS_STORE_PROPERTY].splice(-1, 1, newRoute);
    }
};
exports.replaceCurrentStackRoute = replaceCurrentStackRoute;
// generate route from existing stack on request object.
// splash between stack layer will be deduped
// ["/first/", "/second", "/third/"] => /first/second/third/
const generateRoute = (request) => {
    return request[internal_types_1._LAYERS_STORE_PROPERTY].reduce((acc, sub) => acc.replace(/\/+$/, '') + sub);
};
exports.generateRoute = generateRoute;
//# sourceMappingURL=utils.js.map