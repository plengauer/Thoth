import { MetadataBearer as __MetadataBearer } from "@smithy/types";
import { ConverseStreamRequest, ConverseStreamResponse } from "../models/models_0";
export { __MetadataBearer };
export interface ConverseStreamCommandInput extends ConverseStreamRequest {}
export interface ConverseStreamCommandOutput extends ConverseStreamResponse, __MetadataBearer {}
declare const ConverseStreamCommand_base: {
  new (
    input: ConverseStreamCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    ConverseStreamCommandInput,
    ConverseStreamCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  new (
    input: ConverseStreamCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    ConverseStreamCommandInput,
    ConverseStreamCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  getEndpointParameterInstructions(): import("@smithy/types").EndpointParameterInstructions;
};
export declare class ConverseStreamCommand extends ConverseStreamCommand_base {
  protected static __types: {
    api: {
      input: ConverseStreamRequest;
      output: ConverseStreamResponse;
    };
    sdk: {
      input: ConverseStreamCommandInput;
      output: ConverseStreamCommandOutput;
    };
  };
}
