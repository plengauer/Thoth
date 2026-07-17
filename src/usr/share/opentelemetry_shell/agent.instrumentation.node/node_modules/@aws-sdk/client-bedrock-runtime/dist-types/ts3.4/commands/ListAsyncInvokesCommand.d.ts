import { MetadataBearer as __MetadataBearer } from "@smithy/types";
import { ListAsyncInvokesRequest, ListAsyncInvokesResponse } from "../models/models_0";
export { __MetadataBearer };
export interface ListAsyncInvokesCommandInput extends ListAsyncInvokesRequest {}
export interface ListAsyncInvokesCommandOutput extends ListAsyncInvokesResponse, __MetadataBearer {}
declare const ListAsyncInvokesCommand_base: {
  new (
    input: ListAsyncInvokesCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    ListAsyncInvokesCommandInput,
    ListAsyncInvokesCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  new (
    ...[input]: [] | [ListAsyncInvokesCommandInput]
  ): import("@smithy/core/client").CommandImpl<
    ListAsyncInvokesCommandInput,
    ListAsyncInvokesCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  getEndpointParameterInstructions(): import("@smithy/types").EndpointParameterInstructions;
};
export declare class ListAsyncInvokesCommand extends ListAsyncInvokesCommand_base {
  protected static __types: {
    api: {
      input: ListAsyncInvokesRequest;
      output: ListAsyncInvokesResponse;
    };
    sdk: {
      input: ListAsyncInvokesCommandInput;
      output: ListAsyncInvokesCommandOutput;
    };
  };
}
