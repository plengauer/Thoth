import { MetadataBearer as __MetadataBearer } from "@smithy/types";
import { CountTokensRequest, CountTokensResponse } from "../models/models_0";
export { __MetadataBearer };
export interface CountTokensCommandInput extends CountTokensRequest {}
export interface CountTokensCommandOutput extends CountTokensResponse, __MetadataBearer {}
declare const CountTokensCommand_base: {
  new (
    input: CountTokensCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    CountTokensCommandInput,
    CountTokensCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  new (
    input: CountTokensCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    CountTokensCommandInput,
    CountTokensCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  getEndpointParameterInstructions(): import("@smithy/types").EndpointParameterInstructions;
};
export declare class CountTokensCommand extends CountTokensCommand_base {
  protected static __types: {
    api: {
      input: CountTokensRequest;
      output: CountTokensResponse;
    };
    sdk: {
      input: CountTokensCommandInput;
      output: CountTokensCommandOutput;
    };
  };
}
