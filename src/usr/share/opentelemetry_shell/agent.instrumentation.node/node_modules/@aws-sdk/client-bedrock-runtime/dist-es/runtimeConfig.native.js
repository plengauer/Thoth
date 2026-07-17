import { invalidFunction } from "@smithy/core/client";
import { getRuntimeConfig as getBrowserRuntimeConfig } from "./runtimeConfig.browser";
export const getRuntimeConfig = (config) => {
    const browserDefaults = getBrowserRuntimeConfig(config);
    return {
        ...browserDefaults,
        ...config,
        runtime: "react-native",
        eventStreamPayloadHandlerProvider: config?.eventStreamPayloadHandlerProvider ?? (() => ({
            handle: invalidFunction("event stream request is not supported in ReactNative."),
        })),
    };
};
