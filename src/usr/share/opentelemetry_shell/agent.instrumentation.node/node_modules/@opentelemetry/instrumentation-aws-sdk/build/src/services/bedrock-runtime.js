"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.BedrockRuntimeServiceExtension = void 0;
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
const api_1 = require("@opentelemetry/api");
const semconv_1 = require("../semconv");
const core_1 = require("@opentelemetry/core");
class BedrockRuntimeServiceExtension {
    tokenUsage;
    operationDuration;
    _diag = api_1.diag;
    updateMetricInstruments(meter) {
        // https://opentelemetry.io/docs/specs/semconv/gen-ai/gen-ai-metrics/#metric-gen_aiclienttokenusage
        this.tokenUsage = meter.createHistogram(semconv_1.METRIC_GEN_AI_CLIENT_TOKEN_USAGE, {
            unit: '{token}',
            description: 'Measures number of input and output tokens used',
            valueType: api_1.ValueType.INT,
            advice: {
                explicitBucketBoundaries: [
                    1, 4, 16, 64, 256, 1024, 4096, 16384, 65536, 262144, 1048576, 4194304,
                    16777216, 67108864,
                ],
            },
        });
        // https://opentelemetry.io/docs/specs/semconv/gen-ai/gen-ai-metrics/#metric-gen_aiclientoperationduration
        this.operationDuration = meter.createHistogram(semconv_1.METRIC_GEN_AI_CLIENT_OPERATION_DURATION, {
            unit: 's',
            description: 'GenAI operation duration',
            advice: {
                explicitBucketBoundaries: [
                    0.01, 0.02, 0.04, 0.08, 0.16, 0.32, 0.64, 1.28, 2.56, 5.12, 10.24,
                    20.48, 40.96, 81.92,
                ],
            },
        });
    }
    requestPreSpanHook(request, config, diag) {
        switch (request.commandName) {
            case 'Converse':
                return this.requestPreSpanHookConverse(request, config, diag, false);
            case 'ConverseStream':
                return this.requestPreSpanHookConverse(request, config, diag, true);
            case 'InvokeModel':
                return this.requestPreSpanHookInvokeModel(request, config, diag, false);
            case 'InvokeModelWithResponseStream':
                return this.requestPreSpanHookInvokeModel(request, config, diag, true);
        }
        return {
            isIncoming: false,
        };
    }
    requestPreSpanHookConverse(request, config, diag, isStream) {
        let spanName = semconv_1.GEN_AI_OPERATION_NAME_VALUE_CHAT;
        const spanAttributes = {
            [semconv_1.ATTR_GEN_AI_SYSTEM]: semconv_1.GEN_AI_SYSTEM_VALUE_AWS_BEDROCK,
            [semconv_1.ATTR_GEN_AI_OPERATION_NAME]: semconv_1.GEN_AI_OPERATION_NAME_VALUE_CHAT,
        };
        const modelId = request.commandInput.modelId;
        if (modelId) {
            spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_MODEL] = modelId;
            if (spanName) {
                spanName += ` ${modelId}`;
            }
        }
        const inferenceConfig = request.commandInput.inferenceConfig;
        if (inferenceConfig) {
            const { maxTokens, temperature, topP, stopSequences } = inferenceConfig;
            if (maxTokens !== undefined) {
                spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_MAX_TOKENS] = maxTokens;
            }
            if (temperature !== undefined) {
                spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TEMPERATURE] = temperature;
            }
            if (topP !== undefined) {
                spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TOP_P] = topP;
            }
            if (stopSequences !== undefined) {
                spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_STOP_SEQUENCES] = stopSequences;
            }
        }
        return {
            spanName,
            isIncoming: false,
            isStream,
            spanAttributes,
        };
    }
    requestPreSpanHookInvokeModel(request, config, diag, isStream) {
        let spanName;
        const spanAttributes = {
            [semconv_1.ATTR_GEN_AI_SYSTEM]: semconv_1.GEN_AI_SYSTEM_VALUE_AWS_BEDROCK,
            // add operation name for InvokeModel API
        };
        const modelId = request.commandInput?.modelId;
        if (modelId) {
            spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_MODEL] = modelId;
        }
        if (request.commandInput?.body) {
            const requestBody = JSON.parse(request.commandInput.body);
            if (modelId.includes('amazon.titan')) {
                if (requestBody.textGenerationConfig?.temperature !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TEMPERATURE] =
                        requestBody.textGenerationConfig.temperature;
                }
                if (requestBody.textGenerationConfig?.topP !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TOP_P] =
                        requestBody.textGenerationConfig.topP;
                }
                if (requestBody.textGenerationConfig?.maxTokenCount !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_MAX_TOKENS] =
                        requestBody.textGenerationConfig.maxTokenCount;
                }
                if (requestBody.textGenerationConfig?.stopSequences !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_STOP_SEQUENCES] =
                        requestBody.textGenerationConfig.stopSequences;
                }
            }
            else if (modelId.includes('amazon.nova')) {
                if (requestBody.inferenceConfig?.temperature !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TEMPERATURE] =
                        requestBody.inferenceConfig.temperature;
                }
                if (requestBody.inferenceConfig?.top_p !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TOP_P] =
                        requestBody.inferenceConfig.top_p;
                }
                if (requestBody.inferenceConfig?.max_new_tokens !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_MAX_TOKENS] =
                        requestBody.inferenceConfig.max_new_tokens;
                }
                if (requestBody.inferenceConfig?.stopSequences !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_STOP_SEQUENCES] =
                        requestBody.inferenceConfig.stopSequences;
                }
            }
            else if (modelId.includes('anthropic.claude')) {
                if (requestBody.max_tokens !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_MAX_TOKENS] =
                        requestBody.max_tokens;
                }
                if (requestBody.temperature !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TEMPERATURE] =
                        requestBody.temperature;
                }
                if (requestBody.top_p !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TOP_P] = requestBody.top_p;
                }
                if (requestBody.stop_sequences !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_STOP_SEQUENCES] =
                        requestBody.stop_sequences;
                }
            }
            else if (modelId.includes('meta.llama')) {
                if (requestBody.max_gen_len !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_MAX_TOKENS] =
                        requestBody.max_gen_len;
                }
                if (requestBody.temperature !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TEMPERATURE] =
                        requestBody.temperature;
                }
                if (requestBody.top_p !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TOP_P] = requestBody.top_p;
                }
                // request for meta llama models does not contain stop_sequences field
            }
            else if (modelId.includes('cohere.command-r')) {
                if (requestBody.max_tokens !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_MAX_TOKENS] =
                        requestBody.max_tokens;
                }
                if (requestBody.temperature !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TEMPERATURE] =
                        requestBody.temperature;
                }
                if (requestBody.p !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TOP_P] = requestBody.p;
                }
                if (requestBody.message !== undefined) {
                    // NOTE: We approximate the token count since this value is not directly available in the body
                    // According to Bedrock docs they use (total_chars / 6) to approximate token count for pricing.
                    // https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-prepare.html
                    spanAttributes[semconv_1.ATTR_GEN_AI_USAGE_INPUT_TOKENS] = Math.ceil(requestBody.message.length / 6);
                }
                if (requestBody.stop_sequences !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_STOP_SEQUENCES] =
                        requestBody.stop_sequences;
                }
            }
            else if (modelId.includes('cohere.command')) {
                if (requestBody.max_tokens !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_MAX_TOKENS] =
                        requestBody.max_tokens;
                }
                if (requestBody.temperature !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TEMPERATURE] =
                        requestBody.temperature;
                }
                if (requestBody.p !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TOP_P] = requestBody.p;
                }
                if (requestBody.prompt !== undefined) {
                    // NOTE: We approximate the token count since this value is not directly available in the body
                    // According to Bedrock docs they use (total_chars / 6) to approximate token count for pricing.
                    // https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-prepare.html
                    spanAttributes[semconv_1.ATTR_GEN_AI_USAGE_INPUT_TOKENS] = Math.ceil(requestBody.prompt.length / 6);
                }
                if (requestBody.stop_sequences !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_STOP_SEQUENCES] =
                        requestBody.stop_sequences;
                }
            }
            else if (modelId.includes('mistral')) {
                if (requestBody.prompt !== undefined) {
                    // NOTE: We approximate the token count since this value is not directly available in the body
                    // According to Bedrock docs they use (total_chars / 6) to approximate token count for pricing.
                    // https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-prepare.html
                    spanAttributes[semconv_1.ATTR_GEN_AI_USAGE_INPUT_TOKENS] = Math.ceil(requestBody.prompt.length / 6);
                }
                if (requestBody.max_tokens !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_MAX_TOKENS] =
                        requestBody.max_tokens;
                }
                if (requestBody.temperature !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TEMPERATURE] =
                        requestBody.temperature;
                }
                if (requestBody.top_p !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_TOP_P] = requestBody.top_p;
                }
                if (requestBody.stop !== undefined) {
                    spanAttributes[semconv_1.ATTR_GEN_AI_REQUEST_STOP_SEQUENCES] = requestBody.stop;
                }
            }
        }
        return {
            spanName,
            isIncoming: false,
            isStream,
            spanAttributes,
        };
    }
    responseHook(response, span, tracer, config, startTime) {
        if (!span.isRecording()) {
            return;
        }
        switch (response.request.commandName) {
            case 'Converse':
                return this.responseHookConverse(response, span, tracer, config, startTime);
            case 'ConverseStream':
                return this.responseHookConverseStream(response, span, tracer, config, startTime);
            case 'InvokeModel':
                return this.responseHookInvokeModel(response, span, tracer, config);
            case 'InvokeModelWithResponseStream':
                return this.responseHookInvokeModelWithResponseStream(response, span, tracer, config);
        }
    }
    responseHookConverse(response, span, tracer, config, startTime) {
        const { stopReason, usage } = response.data;
        BedrockRuntimeServiceExtension.setStopReason(span, stopReason);
        this.setUsage(response, span, usage, startTime);
    }
    responseHookConverseStream(response, span, tracer, config, startTime) {
        return {
            ...response.data,
            // Wrap and replace the response stream to allow processing events to telemetry
            // before yielding to the user.
            stream: this.wrapConverseStreamResponse(response, response.data.stream, span, startTime),
        };
    }
    async *wrapConverseStreamResponse(response, stream, span, startTime) {
        try {
            let usage;
            for await (const item of stream) {
                BedrockRuntimeServiceExtension.setStopReason(span, item.messageStop?.stopReason);
                usage = item.metadata?.usage;
                yield item;
            }
            this.setUsage(response, span, usage, startTime);
        }
        finally {
            span.end();
        }
    }
    static setStopReason(span, stopReason) {
        if (stopReason !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [stopReason]);
        }
    }
    setUsage(response, span, usage, startTime) {
        const sharedMetricAttrs = {
            [semconv_1.ATTR_GEN_AI_SYSTEM]: semconv_1.GEN_AI_SYSTEM_VALUE_AWS_BEDROCK,
            [semconv_1.ATTR_GEN_AI_OPERATION_NAME]: semconv_1.GEN_AI_OPERATION_NAME_VALUE_CHAT,
            [semconv_1.ATTR_GEN_AI_REQUEST_MODEL]: response.request.commandInput.modelId,
        };
        const durationSecs = (0, core_1.hrTimeToMilliseconds)((0, core_1.hrTimeDuration)(startTime, (0, core_1.hrTime)())) / 1000;
        this.operationDuration.record(durationSecs, sharedMetricAttrs);
        if (usage) {
            const { inputTokens, outputTokens } = usage;
            if (inputTokens !== undefined) {
                span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_INPUT_TOKENS, inputTokens);
                this.tokenUsage.record(inputTokens, {
                    ...sharedMetricAttrs,
                    [semconv_1.ATTR_GEN_AI_TOKEN_TYPE]: semconv_1.GEN_AI_TOKEN_TYPE_VALUE_INPUT,
                });
            }
            if (outputTokens !== undefined) {
                span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, outputTokens);
                this.tokenUsage.record(outputTokens, {
                    ...sharedMetricAttrs,
                    [semconv_1.ATTR_GEN_AI_TOKEN_TYPE]: semconv_1.GEN_AI_TOKEN_TYPE_VALUE_OUTPUT,
                });
            }
        }
    }
    responseHookInvokeModel(response, span, tracer, config) {
        const currentModelId = response.request.commandInput?.modelId;
        if (response.data?.body) {
            const decodedResponseBody = new TextDecoder().decode(response.data.body);
            const responseBody = JSON.parse(decodedResponseBody);
            if (currentModelId.includes('amazon.titan')) {
                if (responseBody.inputTextTokenCount !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_INPUT_TOKENS, responseBody.inputTextTokenCount);
                }
                if (responseBody.results?.[0]?.tokenCount !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, responseBody.results[0].tokenCount);
                }
                if (responseBody.results?.[0]?.completionReason !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [
                        responseBody.results[0].completionReason,
                    ]);
                }
            }
            else if (currentModelId.includes('amazon.nova')) {
                if (responseBody.usage !== undefined) {
                    if (responseBody.usage.inputTokens !== undefined) {
                        span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_INPUT_TOKENS, responseBody.usage.inputTokens);
                    }
                    if (responseBody.usage.outputTokens !== undefined) {
                        span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, responseBody.usage.outputTokens);
                    }
                }
                if (responseBody.stopReason !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [
                        responseBody.stopReason,
                    ]);
                }
            }
            else if (currentModelId.includes('anthropic.claude')) {
                if (responseBody.usage?.input_tokens !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_INPUT_TOKENS, responseBody.usage.input_tokens);
                }
                if (responseBody.usage?.output_tokens !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, responseBody.usage.output_tokens);
                }
                if (responseBody.stop_reason !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [
                        responseBody.stop_reason,
                    ]);
                }
            }
            else if (currentModelId.includes('meta.llama')) {
                if (responseBody.prompt_token_count !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_INPUT_TOKENS, responseBody.prompt_token_count);
                }
                if (responseBody.generation_token_count !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, responseBody.generation_token_count);
                }
                if (responseBody.stop_reason !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [
                        responseBody.stop_reason,
                    ]);
                }
            }
            else if (currentModelId.includes('cohere.command-r')) {
                if (responseBody.text !== undefined) {
                    // NOTE: We approximate the token count since this value is not directly available in the body
                    // According to Bedrock docs they use (total_chars / 6) to approximate token count for pricing.
                    // https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-prepare.html
                    span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, Math.ceil(responseBody.text.length / 6));
                }
                if (responseBody.finish_reason !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [
                        responseBody.finish_reason,
                    ]);
                }
            }
            else if (currentModelId.includes('cohere.command')) {
                if (responseBody.generations?.[0]?.text !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, 
                    // NOTE: We approximate the token count since this value is not directly available in the body
                    // According to Bedrock docs they use (total_chars / 6) to approximate token count for pricing.
                    // https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-prepare.html
                    Math.ceil(responseBody.generations[0].text.length / 6));
                }
                if (responseBody.generations?.[0]?.finish_reason !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [
                        responseBody.generations[0].finish_reason,
                    ]);
                }
            }
            else if (currentModelId.includes('mistral')) {
                if (responseBody.outputs?.[0]?.text !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, 
                    // NOTE: We approximate the token count since this value is not directly available in the body
                    // According to Bedrock docs they use (total_chars / 6) to approximate token count for pricing.
                    // https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-prepare.html
                    Math.ceil(responseBody.outputs[0].text.length / 6));
                }
                if (responseBody.outputs?.[0]?.stop_reason !== undefined) {
                    span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [
                        responseBody.outputs[0].stop_reason,
                    ]);
                }
            }
        }
    }
    async responseHookInvokeModelWithResponseStream(response, span, tracer, config) {
        const stream = response.data?.body;
        const modelId = response.request.commandInput?.modelId;
        if (!stream || !modelId)
            return;
        // Replace the original response body with our instrumented stream.
        // - Defers span.end() until the entire stream is consumed
        // This ensures downstream consumers still receive the full stream correctly,
        // while OpenTelemetry can record span attributes from streamed data.
        response.data.body = async function* () {
            try {
                for await (const chunk of stream) {
                    const parsedChunk = this.parseChunk(chunk?.chunk?.bytes);
                    if (!parsedChunk) {
                        // pass through
                    }
                    else if (modelId.includes('amazon.titan')) {
                        BedrockRuntimeServiceExtension.recordTitanAttributes(parsedChunk, span);
                    }
                    else if (modelId.includes('anthropic.claude')) {
                        BedrockRuntimeServiceExtension.recordClaudeAttributes(parsedChunk, span);
                    }
                    else if (modelId.includes('amazon.nova')) {
                        BedrockRuntimeServiceExtension.recordNovaAttributes(parsedChunk, span);
                    }
                    else if (modelId.includes('meta.llama')) {
                        BedrockRuntimeServiceExtension.recordLlamaAttributes(parsedChunk, span);
                    }
                    else if (modelId.includes('cohere.command-r')) {
                        BedrockRuntimeServiceExtension.recordCohereRAttributes(parsedChunk, span);
                    }
                    else if (modelId.includes('cohere.command')) {
                        BedrockRuntimeServiceExtension.recordCohereAttributes(parsedChunk, span);
                    }
                    else if (modelId.includes('mistral')) {
                        BedrockRuntimeServiceExtension.recordMistralAttributes(parsedChunk, span);
                    }
                    yield chunk;
                }
            }
            finally {
                span.end();
            }
        }.bind(this)();
        return response.data;
    }
    parseChunk(bytes) {
        if (!bytes || !(bytes instanceof Uint8Array))
            return null;
        try {
            const str = Buffer.from(bytes).toString('utf-8');
            return JSON.parse(str);
        }
        catch (err) {
            this._diag.warn('Failed to parse streamed chunk', err);
            return null;
        }
    }
    static recordNovaAttributes(parsedChunk, span) {
        if (parsedChunk.metadata?.usage !== undefined) {
            if (parsedChunk.metadata?.usage.inputTokens !== undefined) {
                span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_INPUT_TOKENS, parsedChunk.metadata.usage.inputTokens);
            }
            if (parsedChunk.metadata?.usage.outputTokens !== undefined) {
                span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, parsedChunk.metadata.usage.outputTokens);
            }
        }
        if (parsedChunk.messageStop?.stopReason !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [
                parsedChunk.messageStop.stopReason,
            ]);
        }
    }
    static recordClaudeAttributes(parsedChunk, span) {
        if (parsedChunk.message?.usage?.input_tokens !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_INPUT_TOKENS, parsedChunk.message.usage.input_tokens);
        }
        if (parsedChunk.message?.usage?.output_tokens !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, parsedChunk.message.usage.output_tokens);
        }
        if (parsedChunk.delta?.stop_reason !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [
                parsedChunk.delta.stop_reason,
            ]);
        }
    }
    static recordTitanAttributes(parsedChunk, span) {
        if (parsedChunk.inputTextTokenCount !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_INPUT_TOKENS, parsedChunk.inputTextTokenCount);
        }
        if (parsedChunk.totalOutputTextTokenCount !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, parsedChunk.totalOutputTextTokenCount);
        }
        if (parsedChunk.completionReason !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [
                parsedChunk.completionReason,
            ]);
        }
    }
    static recordLlamaAttributes(parsedChunk, span) {
        if (parsedChunk.prompt_token_count !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_INPUT_TOKENS, parsedChunk.prompt_token_count);
        }
        if (parsedChunk.generation_token_count !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, parsedChunk.generation_token_count);
        }
        if (parsedChunk.stop_reason !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [
                parsedChunk.stop_reason,
            ]);
        }
    }
    static recordMistralAttributes(parsedChunk, span) {
        if (parsedChunk.outputs?.[0]?.text !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, 
            // NOTE: We approximate the token count since this value is not directly available in the body
            // According to Bedrock docs they use (total_chars / 6) to approximate token count for pricing.
            // https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-prepare.html
            Math.ceil(parsedChunk.outputs[0].text.length / 6));
        }
        if (parsedChunk.outputs?.[0]?.stop_reason !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [
                parsedChunk.outputs[0].stop_reason,
            ]);
        }
    }
    static recordCohereAttributes(parsedChunk, span) {
        if (parsedChunk.generations?.[0]?.text !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, 
            // NOTE: We approximate the token count since this value is not directly available in the body
            // According to Bedrock docs they use (total_chars / 6) to approximate token count for pricing.
            // https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-prepare.html
            Math.ceil(parsedChunk.generations[0].text.length / 6));
        }
        if (parsedChunk.generations?.[0]?.finish_reason !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [
                parsedChunk.generations[0].finish_reason,
            ]);
        }
    }
    static recordCohereRAttributes(parsedChunk, span) {
        if (parsedChunk.text !== undefined) {
            // NOTE: We approximate the token count since this value is not directly available in the body
            // According to Bedrock docs they use (total_chars / 6) to approximate token count for pricing.
            // https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-prepare.html
            span.setAttribute(semconv_1.ATTR_GEN_AI_USAGE_OUTPUT_TOKENS, Math.ceil(parsedChunk.text.length / 6));
        }
        if (parsedChunk.finish_reason !== undefined) {
            span.setAttribute(semconv_1.ATTR_GEN_AI_RESPONSE_FINISH_REASONS, [
                parsedChunk.finish_reason,
            ]);
        }
    }
}
exports.BedrockRuntimeServiceExtension = BedrockRuntimeServiceExtension;
//# sourceMappingURL=bedrock-runtime.js.map