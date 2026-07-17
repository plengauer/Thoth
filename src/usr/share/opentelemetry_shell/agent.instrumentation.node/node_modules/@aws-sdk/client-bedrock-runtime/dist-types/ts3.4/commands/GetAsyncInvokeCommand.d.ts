import { MetadataBearer as __MetadataBearer } from "@smithy/types";
import { GetAsyncInvokeRequest, GetAsyncInvokeResponse } from "../models/models_0";
export { __MetadataBearer };
export interface GetAsyncInvokeCommandInput extends GetAsyncInvokeRequest {}
export interface GetAsyncInvokeCommandOutput extends GetAsyncInvokeResponse, __MetadataBearer {}
declare const GetAsyncInvokeCommand_base: {
  new (
    input: GetAsyncInvokeCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    GetAsyncInvokeCommandInput,
    GetAsyncInvokeCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  new (
    input: GetAsyncInvokeCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    GetAsyncInvokeCommandInput,
    GetAsyncInvokeCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  getEndpointParameterInstructions(): import("@smithy/types").EndpointParameterInstructions;
};
export declare class GetAsyncInvokeCommand extends GetAsyncInvokeCommand_base {
  protected static __types: {
    api: {
      input: GetAsyncInvokeRequest;
      output: GetAsyncInvokeResponse;
    };
    sdk: {
      input: GetAsyncInvokeCommandInput;
      output: GetAsyncInvokeCommandOutput;
    };
  };
}
