"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AttributeNames = void 0;
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
var AttributeNames;
(function (AttributeNames) {
    AttributeNames["AWS_OPERATION"] = "aws.operation";
    AttributeNames["CLOUD_REGION"] = "cloud.region";
    AttributeNames["AWS_SERVICE_API"] = "aws.service.api";
    AttributeNames["AWS_SERVICE_NAME"] = "aws.service.name";
    AttributeNames["AWS_SERVICE_IDENTIFIER"] = "aws.service.identifier";
    AttributeNames["AWS_REQUEST_ID"] = "aws.request.id";
    AttributeNames["AWS_REQUEST_EXTENDED_ID"] = "aws.request.extended_id";
    AttributeNames["AWS_SIGNATURE_VERSION"] = "aws.signature.version";
    // TODO: Add these semantic attributes to:
    // - https://github.com/open-telemetry/opentelemetry-js/blob/main/packages/opentelemetry-semantic-conventions/src/trace/SemanticAttributes.ts
    // For S3, see specification: https://github.com/open-telemetry/semantic-conventions/blob/main/docs/object-stores/s3.md
    AttributeNames["AWS_S3_BUCKET"] = "aws.s3.bucket";
    AttributeNames["AWS_KINESIS_STREAM_NAME"] = "aws.kinesis.stream.name";
})(AttributeNames = exports.AttributeNames || (exports.AttributeNames = {}));
//# sourceMappingURL=enums.js.map