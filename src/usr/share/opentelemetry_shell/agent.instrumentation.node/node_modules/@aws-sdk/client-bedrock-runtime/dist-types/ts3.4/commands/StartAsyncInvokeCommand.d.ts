import { MetadataBearer as __MetadataBearer } from "@smithy/types";
import { StartAsyncInvokeRequest, StartAsyncInvokeResponse } from "../models/models_0";
export { __MetadataBearer };
export interface StartAsyncInvokeCommandInput extends StartAsyncInvokeRequest {}
export interface StartAsyncInvokeCommandOutput extends StartAsyncInvokeResponse, __MetadataBearer {}
declare const StartAsyncInvokeCommand_base: {
  new (
    input: StartAsyncInvokeCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    StartAsyncInvokeCommandInput,
    StartAsyncInvokeCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  new (
    input: StartAsyncInvokeCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    StartAsyncInvokeCommandInput,
    StartAsyncInvokeCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  getEndpointParameterInstructions(): import("@smithy/types").EndpointParameterInstructions;
};
export declare class StartAsyncInvokeCommand extends StartAsyncInvokeCommand_base {
  protected static __types: {
    api: {
      input: StartAsyncInvokeRequest;
      output: StartAsyncInvokeResponse;
    };
    sdk: {
      input: StartAsyncInvokeCommandInput;
      output: StartAsyncInvokeCommandOutput;
    };
  };
}
