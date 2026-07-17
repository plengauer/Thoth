"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.KinesisServiceExtension = void 0;
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
const api_1 = require("@opentelemetry/api");
const enums_1 = require("../enums");
class KinesisServiceExtension {
    requestPreSpanHook(request, _config) {
        const streamName = request.commandInput?.StreamName;
        const spanKind = api_1.SpanKind.CLIENT;
        const spanAttributes = {};
        if (streamName) {
            spanAttributes[enums_1.AttributeNames.AWS_KINESIS_STREAM_NAME] = streamName;
        }
        const isIncoming = false;
        return {
            isIncoming,
            spanAttributes,
            spanKind,
        };
    }
}
exports.KinesisServiceExtension = KinesisServiceExtension;
//# sourceMappingURL=kinesis.js.map