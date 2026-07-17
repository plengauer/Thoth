"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.StepFunctionsServiceExtension = void 0;
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
const api_1 = require("@opentelemetry/api");
const semconv_1 = require("../semconv");
class StepFunctionsServiceExtension {
    requestPreSpanHook(request, _config) {
        const stateMachineArn = request.commandInput?.stateMachineArn;
        const activityArn = request.commandInput?.activityArn;
        const spanKind = api_1.SpanKind.CLIENT;
        const spanAttributes = {};
        if (stateMachineArn) {
            spanAttributes[semconv_1.ATTR_AWS_STEP_FUNCTIONS_STATE_MACHINE_ARN] =
                stateMachineArn;
        }
        if (activityArn) {
            spanAttributes[semconv_1.ATTR_AWS_STEP_FUNCTIONS_ACTIVITY_ARN] = activityArn;
        }
        return {
            isIncoming: false,
            spanAttributes,
            spanKind,
        };
    }
}
exports.StepFunctionsServiceExtension = StepFunctionsServiceExtension;
//# sourceMappingURL=stepfunctions.js.map