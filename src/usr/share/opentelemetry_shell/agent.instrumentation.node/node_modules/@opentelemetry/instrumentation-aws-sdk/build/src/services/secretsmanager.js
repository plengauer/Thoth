"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SecretsManagerServiceExtension = void 0;
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
const api_1 = require("@opentelemetry/api");
const semconv_1 = require("../semconv");
class SecretsManagerServiceExtension {
    requestPreSpanHook(request, _config) {
        const secretId = request.commandInput?.SecretId;
        const spanKind = api_1.SpanKind.CLIENT;
        let spanName;
        const spanAttributes = {};
        if (typeof secretId === 'string' &&
            secretId.startsWith('arn:aws:secretsmanager:')) {
            spanAttributes[semconv_1.ATTR_AWS_SECRETSMANAGER_SECRET_ARN] = secretId;
        }
        return {
            isIncoming: false,
            spanAttributes,
            spanKind,
            spanName,
        };
    }
    responseHook(response, span, tracer, config) {
        const secretArn = response.data?.ARN;
        if (secretArn) {
            span.setAttribute(semconv_1.ATTR_AWS_SECRETSMANAGER_SECRET_ARN, secretArn);
        }
    }
}
exports.SecretsManagerServiceExtension = SecretsManagerServiceExtension;
//# sourceMappingURL=secretsmanager.js.map