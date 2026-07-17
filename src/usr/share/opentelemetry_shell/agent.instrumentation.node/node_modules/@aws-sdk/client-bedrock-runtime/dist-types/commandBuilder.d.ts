import type { EndpointParameterInstructions } from "@smithy/types";
import type { BedrockRuntimeClientResolvedConfig, ServiceInputTypes, ServiceOutputTypes } from "./BedrockRuntimeClient";
/**
 * @internal
 */
export declare const command: <I extends ServiceInputTypes, O extends ServiceOutputTypes>(added: EndpointParameterInstructions, plugins: (CommandCtor: any, clientStack: any, config: any, options: any) => import("@smithy/types").Pluggable<any, any>[], op: string, $: import("@smithy/types").StaticOperationSchema, smithyContext?: Record<string, unknown>) => {
    new (input: I): import("@smithy/core/client").CommandImpl<I, O, BedrockRuntimeClientResolvedConfig, ServiceInputTypes, ServiceOutputTypes>;
    new (...[input]: import("@smithy/types").OptionalParameter<I>): import("@smithy/core/client").CommandImpl<I, O, BedrockRuntimeClientResolvedConfig, ServiceInputTypes, ServiceOutputTypes>;
    getEndpointParameterInstructions(): EndpointParameterInstructions;
};
/**
 * @internal
 */
export declare const _ep0: EndpointParameterInstructions;
/**
 * @internal
 */
export declare const _mw0: (Command: any, cs: any, config: any, o: any) => never[];
/**
 * @internal
 */
export declare const _mw1: (Command: any, cs: any, config: any, o: any) => import("@smithy/types").Pluggable<any, any>[];
