"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.bindPromise = exports.extractAttributesFromNormalizedRequest = exports.normalizeV3Request = exports.removeSuffixFromStringIfExists = void 0;
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
const api_1 = require("@opentelemetry/api");
const semconv_1 = require("./semconv");
const enums_1 = require("./enums");
const removeSuffixFromStringIfExists = (str, suffixToRemove) => {
    const suffixLength = suffixToRemove.length;
    return str?.slice(-suffixLength) === suffixToRemove
        ? str.slice(0, str.length - suffixLength)
        : str;
};
exports.removeSuffixFromStringIfExists = removeSuffixFromStringIfExists;
const normalizeV3Request = (serviceName, commandNameWithSuffix, commandInput, region) => {
    return {
        serviceName: serviceName?.replace(/\s+/g, ''),
        commandName: (0, exports.removeSuffixFromStringIfExists)(commandNameWithSuffix, 'Command'),
        commandInput,
        region,
    };
};
exports.normalizeV3Request = normalizeV3Request;
const extractAttributesFromNormalizedRequest = (normalizedRequest) => {
    return {
        [semconv_1.ATTR_RPC_SYSTEM]: 'aws-api',
        [semconv_1.ATTR_RPC_METHOD]: normalizedRequest.commandName,
        [semconv_1.ATTR_RPC_SERVICE]: normalizedRequest.serviceName,
        [enums_1.AttributeNames.CLOUD_REGION]: normalizedRequest.region,
    };
};
exports.extractAttributesFromNormalizedRequest = extractAttributesFromNormalizedRequest;
const bindPromise = (target, contextForCallbacks, rebindCount = 1) => {
    const origThen = target.then;
    target.then = function (onFulfilled, onRejected) {
        const newOnFulfilled = api_1.context.bind(contextForCallbacks, onFulfilled);
        const newOnRejected = api_1.context.bind(contextForCallbacks, onRejected);
        const patchedPromise = origThen.call(this, newOnFulfilled, newOnRejected);
        return rebindCount > 1
            ? (0, exports.bindPromise)(patchedPromise, contextForCallbacks, rebindCount - 1)
            : patchedPromise;
    };
    return target;
};
exports.bindPromise = bindPromise;
//# sourceMappingURL=utils.js.map