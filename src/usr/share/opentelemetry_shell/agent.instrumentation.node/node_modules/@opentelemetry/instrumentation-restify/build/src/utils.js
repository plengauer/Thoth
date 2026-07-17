"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.isAsyncFunction = exports.isPromise = void 0;
// util.types.isPromise is supported from 10.0.0
const isPromise = (value) => {
    return !!(value &&
        typeof value.then === 'function' &&
        typeof value.catch === 'function' &&
        value.toString() === '[object Promise]');
};
exports.isPromise = isPromise;
// util.types.isAsyncFunction is supported from 10.0.0
const isAsyncFunction = (value) => {
    return !!(value &&
        typeof value === 'function' &&
        value.constructor?.name === 'AsyncFunction');
};
exports.isAsyncFunction = isAsyncFunction;
//# sourceMappingURL=utils.js.map