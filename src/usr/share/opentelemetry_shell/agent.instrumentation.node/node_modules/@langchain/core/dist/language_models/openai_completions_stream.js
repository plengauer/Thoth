import { __exportAll } from "../_virtual/_rolldown/runtime.js";
import { finalizeContentBlock } from "./compat.js";
//#region src/language_models/openai_completions_stream.ts
/**
* Converts OpenAI Chat Completions-shaped stream chunks into
* {@link ChatModelStreamEvent}s.
*
* Used by `@langchain/openai` and OpenAI-compatible providers (Groq, Mistral,
* OpenRouter, IBM watsonx, etc.) without requiring a dependency on
* `@langchain/openai`.
*
* @module
*/
var openai_completions_stream_exports = /* @__PURE__ */ __exportAll({ convertOpenAICompletionsStream: () => convertOpenAICompletionsStream });
/**
* Convert an async iterable of OpenAI Chat Completions-shaped stream chunks into
* LangChain `ChatModelStreamEvent`s with typed deltas.
*/
async function* convertOpenAICompletionsStream(source, options = {}) {
	const shouldStreamUsage = options.streamUsage ?? true;
	const provider = options.provider ?? "openai";
	const mapChunk = options.mapChunk;
	const blockAccumulators = /* @__PURE__ */ new Map();
	const blockKeyToIndex = /* @__PURE__ */ new Map();
	let nextBlockIndex = 0;
	let messageStarted = false;
	let usageSnapshot;
	let finishReason;
	let responseMetadata;
	let emittedProviderMetadata = false;
	const getOrCreateBlockIndex = (key, initial) => {
		const existing = blockKeyToIndex.get(key);
		if (existing !== void 0) return {
			index: existing,
			isNew: false
		};
		const index = nextBlockIndex++;
		blockKeyToIndex.set(key, index);
		blockAccumulators.set(index, { ...initial });
		return {
			index,
			isNew: true
		};
	};
	for await (let data of source) {
		if (mapChunk) data = mapChunk(data);
		if (!messageStarted) {
			messageStarted = true;
			yield {
				event: "message-start",
				id: data.id
			};
		}
		if (!emittedProviderMetadata && (data.model || data.service_tier)) {
			emittedProviderMetadata = true;
			yield {
				event: "provider",
				provider,
				name: "stream_metadata",
				payload: {
					model: data.model,
					service_tier: data.service_tier
				}
			};
		}
		if (data.usage && shouldStreamUsage) {
			usageSnapshot = buildUsageSnapshot(data.usage);
			yield {
				event: "usage",
				usage: usageSnapshot
			};
		}
		const groqUsage = data.x_groq?.usage;
		if (groqUsage && shouldStreamUsage) {
			usageSnapshot = buildGroqUsageSnapshot(groqUsage);
			yield {
				event: "usage",
				usage: usageSnapshot
			};
		}
		const choice = data.choices?.[0];
		if (!choice) continue;
		if (choice.finish_reason != null) {
			finishReason = mapFinishReason(choice.finish_reason);
			responseMetadata = buildResponseMetadata(data, choice);
		}
		const { delta } = choice;
		if (!delta) continue;
		const reasoningText = getReasoningDeltaText(delta);
		if (reasoningText) {
			const { index, isNew } = getOrCreateBlockIndex("reasoning", {
				type: "reasoning",
				reasoning: ""
			});
			if (isNew) yield {
				event: "content-block-start",
				index,
				content: {
					type: "reasoning",
					reasoning: ""
				}
			};
			const acc = blockAccumulators.get(index);
			acc.reasoning = (acc.reasoning ?? "") + reasoningText;
			yield {
				event: "content-block-delta",
				index,
				delta: {
					type: "reasoning-delta",
					reasoning: reasoningText
				}
			};
		}
		if (delta.content) {
			const { index, isNew } = getOrCreateBlockIndex("text", {
				type: "text",
				text: ""
			});
			if (isNew) yield {
				event: "content-block-start",
				index,
				content: {
					type: "text",
					text: ""
				}
			};
			const acc = blockAccumulators.get(index);
			acc.text = (acc.text ?? "") + delta.content;
			yield {
				event: "content-block-delta",
				index,
				delta: {
					type: "text-delta",
					text: delta.content
				}
			};
		}
		if (Array.isArray(delta.tool_calls)) for (const rawToolCall of delta.tool_calls) {
			const toolIndex = rawToolCall.index ?? 0;
			const { index, isNew } = getOrCreateBlockIndex(`tool:${toolIndex}`, {
				type: "tool_call_chunk",
				id: rawToolCall.id,
				name: rawToolCall.function?.name,
				args: "",
				index: toolIndex
			});
			if (isNew) yield {
				event: "content-block-start",
				index,
				content: {
					type: "tool_call_chunk",
					id: rawToolCall.id,
					name: rawToolCall.function?.name,
					args: "",
					index: toolIndex
				}
			};
			const acc = blockAccumulators.get(index);
			if (rawToolCall.id != null) acc.id = rawToolCall.id;
			if (rawToolCall.function?.name != null) acc.name = rawToolCall.function.name;
			const argDelta = rawToolCall.function?.arguments ?? "";
			acc.args = (acc.args ?? "") + argDelta;
			yield {
				event: "content-block-delta",
				index,
				delta: {
					type: "block-delta",
					fields: {
						type: "tool_call_chunk",
						...acc.id != null ? { id: acc.id } : {},
						...acc.name != null ? { name: acc.name } : {},
						args: acc.args
					}
				}
			};
		}
		if (delta.audio) {
			const { index, isNew } = getOrCreateBlockIndex("audio", {
				type: "audio",
				id: delta.audio.id,
				data: "",
				mimeType: "audio/pcm",
				transcript: delta.audio.transcript ?? ""
			});
			if (isNew) yield {
				event: "content-block-start",
				index,
				content: {
					type: "audio",
					id: delta.audio.id,
					data: "",
					mimeType: "audio/pcm",
					transcript: delta.audio.transcript ?? ""
				}
			};
			const acc = blockAccumulators.get(index);
			if (delta.audio.transcript) {
				acc.transcript = (acc.transcript ?? "") + delta.audio.transcript;
				yield {
					event: "content-block-delta",
					index,
					delta: {
						type: "block-delta",
						fields: {
							type: "audio",
							transcript: acc.transcript
						}
					}
				};
			}
			if (delta.audio.data) {
				acc.data = (acc.data ?? "") + delta.audio.data;
				yield {
					event: "content-block-delta",
					index,
					delta: {
						type: "data-delta",
						data: delta.audio.data,
						encoding: "base64"
					}
				};
			}
		}
		if (delta.function_call) yield {
			event: "provider",
			provider,
			name: "function_call",
			payload: delta.function_call
		};
		if (choice.logprobs) yield {
			event: "provider",
			provider,
			name: "logprobs",
			payload: choice.logprobs
		};
	}
	for (const [index, acc] of blockAccumulators) yield {
		event: "content-block-finish",
		index,
		content: finalizeContentBlock(acc)
	};
	yield {
		event: "message-finish",
		reason: finishReason,
		...usageSnapshot ? { usage: usageSnapshot } : {},
		...responseMetadata ? { responseMetadata } : {}
	};
}
function getReasoningDeltaText(delta) {
	const reasoning = delta.reasoning_content ?? delta.reasoning;
	return typeof reasoning === "string" && reasoning.length > 0 ? reasoning : void 0;
}
function buildGroqUsageSnapshot(usage) {
	return {
		input_tokens: usage.prompt_tokens ?? 0,
		output_tokens: usage.completion_tokens ?? 0,
		total_tokens: usage.total_tokens ?? 0
	};
}
function mapFinishReason(reason) {
	switch (reason) {
		case "stop": return "stop";
		case "length":
		case "max_tokens": return "length";
		case "tool_calls":
		case "function_call": return "tool_use";
		case "content_filter": return "content_filter";
		default: return "stop";
	}
}
function buildUsageSnapshot(usage) {
	const inputTokenDetails = {
		...usage.prompt_tokens_details?.audio_tokens != null && { audio: usage.prompt_tokens_details.audio_tokens },
		...usage.prompt_tokens_details?.cached_tokens != null && { cache_read: usage.prompt_tokens_details.cached_tokens }
	};
	const outputTokenDetails = {
		...usage.completion_tokens_details?.audio_tokens != null && { audio: usage.completion_tokens_details.audio_tokens },
		...usage.completion_tokens_details?.reasoning_tokens != null && { reasoning: usage.completion_tokens_details.reasoning_tokens }
	};
	return {
		input_tokens: usage.prompt_tokens ?? 0,
		output_tokens: usage.completion_tokens ?? 0,
		total_tokens: usage.total_tokens ?? 0,
		...Object.keys(inputTokenDetails).length > 0 && { input_token_details: inputTokenDetails },
		...Object.keys(outputTokenDetails).length > 0 && { output_token_details: outputTokenDetails }
	};
}
function buildResponseMetadata(data, choice) {
	return {
		model_provider: "openai",
		model_name: data.model,
		system_fingerprint: data.system_fingerprint,
		service_tier: data.service_tier,
		finish_reason: choice.finish_reason,
		...data.usage ? { usage: data.usage } : {}
	};
}
//#endregion
export { convertOpenAICompletionsStream, openai_completions_stream_exports };

//# sourceMappingURL=openai_completions_stream.js.map