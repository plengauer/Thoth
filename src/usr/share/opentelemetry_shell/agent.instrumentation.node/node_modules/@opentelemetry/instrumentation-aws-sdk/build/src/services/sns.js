"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SnsServiceExtension = void 0;
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
const api_1 = require("@opentelemetry/api");
const semconv_1 = require("../semconv");
const semconv_obsolete_1 = require("../semconv-obsolete");
const MessageAttributes_1 = require("./MessageAttributes");
class SnsServiceExtension {
    requestPreSpanHook(request, _config) {
        let spanKind = api_1.SpanKind.CLIENT;
        let spanName = `SNS ${request.commandName}`;
        const spanAttributes = {
            [semconv_1.ATTR_MESSAGING_SYSTEM]: 'aws.sns',
        };
        if (request.commandName === 'Publish') {
            spanKind = api_1.SpanKind.PRODUCER;
            spanAttributes[semconv_obsolete_1.ATTR_MESSAGING_DESTINATION_KIND] =
                semconv_obsolete_1.MESSAGING_DESTINATION_KIND_VALUE_TOPIC;
            const { TopicArn, TargetArn, PhoneNumber } = request.commandInput;
            spanAttributes[semconv_obsolete_1.ATTR_MESSAGING_DESTINATION] = this.extractDestinationName(TopicArn, TargetArn, PhoneNumber);
            // ToDO: Use ATTR_MESSAGING_DESTINATION_NAME when implemented
            spanAttributes['messaging.destination.name'] =
                TopicArn || TargetArn || PhoneNumber || 'unknown';
            spanName = `${PhoneNumber
                ? 'phone_number'
                : spanAttributes[semconv_obsolete_1.ATTR_MESSAGING_DESTINATION]} send`;
        }
        const topicArn = request.commandInput?.TopicArn;
        if (topicArn) {
            spanAttributes[semconv_1.ATTR_AWS_SNS_TOPIC_ARN] = topicArn;
        }
        return {
            isIncoming: false,
            spanAttributes,
            spanKind,
            spanName,
        };
    }
    requestPostSpanHook(request) {
        if (request.commandName === 'Publish') {
            const origMessageAttributes = request.commandInput['MessageAttributes'] ?? {};
            if (origMessageAttributes) {
                request.commandInput['MessageAttributes'] = (0, MessageAttributes_1.injectPropagationContext)(origMessageAttributes);
            }
        }
    }
    responseHook(response, span, tracer, config) {
        const topicArn = response.data?.TopicArn;
        if (topicArn) {
            span.setAttribute(semconv_1.ATTR_AWS_SNS_TOPIC_ARN, topicArn);
        }
    }
    extractDestinationName(topicArn, targetArn, phoneNumber) {
        if (topicArn || targetArn) {
            const arn = topicArn ?? targetArn;
            try {
                return arn.substring(arn.lastIndexOf(':') + 1);
            }
            catch (err) {
                return arn;
            }
        }
        else if (phoneNumber) {
            return phoneNumber;
        }
        else {
            return 'unknown';
        }
    }
}
exports.SnsServiceExtension = SnsServiceExtension;
//# sourceMappingURL=sns.js.map