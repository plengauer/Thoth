import { getEventStreamPlugin } from "@aws-sdk/middleware-eventstream";
import { getWebSocketPlugin } from "@aws-sdk/middleware-websocket";
import { makeBuilder } from "@smithy/core/client";
import { getEndpointPlugin } from "@smithy/core/endpoints";
import { commonParams } from "./endpoint/EndpointParameters";
export const command = makeBuilder(commonParams, "AmazonBedrockFrontendService", "BedrockRuntimeClient", getEndpointPlugin);
export const _ep0 = {};
export const _mw0 = (Command, cs, config, o) => [];
export const _mw1 = (Command, cs, config, o) => [
    getEventStreamPlugin(config),
    getWebSocketPlugin(config, {
        headerPrefix: "x-amz-bedrock-",
    }),
];
