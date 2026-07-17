"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.renameHttpSpan = exports.isInternal = void 0;
// Detect whether a function is a router package internal plumbing handler
const isInternal = (fn, constants) => {
    // Note that both of those functions are sync
    if (fn.name === 'handle' && fn.toString() === constants?.handleFunctionBody) {
        return true;
    }
    if (fn.name === 'router' && fn.toString() === constants?.routeFunctionBody) {
        return true;
    }
    return false;
};
exports.isInternal = isInternal;
const renameHttpSpan = (span, method, route) => {
    if (typeof method === 'string' &&
        typeof route === 'string' &&
        span?.name?.startsWith('HTTP ')) {
        span.updateName(`${method.toUpperCase()} ${route}`);
    }
};
exports.renameHttpSpan = renameHttpSpan;
//# sourceMappingURL=utils.js.map