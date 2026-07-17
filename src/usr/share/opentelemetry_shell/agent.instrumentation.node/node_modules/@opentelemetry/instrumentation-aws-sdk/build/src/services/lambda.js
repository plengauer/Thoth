"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.LambdaServiceExtension = void 0;
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
const api_1 = require("@opentelemetry/api");
const semconv_1 = require("../semconv");
const semconv_obsolete_1 = require("../semconv-obsolete");
const api_2 = require("@opentelemetry/api");
class LambdaCommands {
    static Invoke = 'Invoke';
}
class LambdaServiceExtension {
    requestPreSpanHook(request, _config) {
        const functionName = this.extractFunctionName(request.commandInput);
        let spanAttributes = {};
        let spanName;
        switch (request.commandName) {
            case 'Invoke':
                spanAttributes = {
                    [semconv_1.ATTR_FAAS_INVOKED_NAME]: functionName,
                    [semconv_1.ATTR_FAAS_INVOKED_PROVIDER]: 'aws',
                };
                if (request.region) {
                    spanAttributes[semconv_1.ATTR_FAAS_INVOKED_REGION] = request.region;
                }
                spanName = `${functionName} ${LambdaCommands.Invoke}`;
                break;
        }
        return {
            isIncoming: false,
            spanAttributes,
            spanKind: api_1.SpanKind.CLIENT,
            spanName,
        };
    }
    requestPostSpanHook = (request) => {
        switch (request.commandName) {
            case LambdaCommands.Invoke:
                {
                    if (request.commandInput) {
                        request.commandInput.ClientContext = injectLambdaPropagationContext(request.commandInput.ClientContext);
                    }
                }
                break;
        }
    };
    responseHook(response, span, tracer, config) {
        switch (response.request.commandName) {
            case LambdaCommands.Invoke:
                {
                    span.setAttribute(semconv_obsolete_1.ATTR_FAAS_EXECUTION, response.requestId);
                }
                break;
        }
    }
    extractFunctionName = (commandInput) => {
        return commandInput?.FunctionName;
    };
}
exports.LambdaServiceExtension = LambdaServiceExtension;
const injectLambdaPropagationContext = (clientContext) => {
    try {
        const propagatedContext = {};
        api_2.propagation.inject(api_2.context.active(), propagatedContext);
        const parsedClientContext = clientContext
            ? JSON.parse(Buffer.from(clientContext, 'base64').toString('utf8'))
            : {};
        const updatedClientContext = {
            ...parsedClientContext,
            custom: {
                ...parsedClientContext.custom,
                ...propagatedContext,
            },
        };
        const encodedClientContext = Buffer.from(JSON.stringify(updatedClientContext)).toString('base64');
        // The length of client context is capped at 3583 bytes of base64 encoded data
        // (https://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html#API_Invoke_RequestSyntax)
        if (encodedClientContext.length > 3583) {
            api_1.diag.warn('lambda instrumentation: cannot set context propagation on lambda invoke parameters due to ClientContext length limitations.');
            return clientContext;
        }
        return encodedClientContext;
    }
    catch (e) {
        api_1.diag.debug('lambda instrumentation: failed to set context propagation on ClientContext', e);
        return clientContext;
    }
};
//# sourceMappingURL=lambda.js.map