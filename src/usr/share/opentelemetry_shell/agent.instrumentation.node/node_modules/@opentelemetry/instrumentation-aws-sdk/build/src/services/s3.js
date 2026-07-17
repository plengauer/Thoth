"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.S3ServiceExtension = void 0;
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
const api_1 = require("@opentelemetry/api");
const enums_1 = require("../enums");
class S3ServiceExtension {
    requestPreSpanHook(request, _config) {
        const bucketName = request.commandInput?.Bucket;
        const spanKind = api_1.SpanKind.CLIENT;
        const spanAttributes = {};
        if (bucketName) {
            spanAttributes[enums_1.AttributeNames.AWS_S3_BUCKET] = bucketName;
        }
        const isIncoming = false;
        return {
            isIncoming,
            spanAttributes,
            spanKind,
        };
    }
}
exports.S3ServiceExtension = S3ServiceExtension;
//# sourceMappingURL=s3.js.map