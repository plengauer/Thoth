import { MetadataBearer as __MetadataBearer } from "@smithy/types";
import { ConverseRequest, ConverseResponse } from "../models/models_0";
export { __MetadataBearer };
export interface ConverseCommandInput extends ConverseRequest {}
export interface ConverseCommandOutput extends ConverseResponse, __MetadataBearer {}
declare const ConverseCommand_base: {
  new (
    input: ConverseCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    ConverseCommandInput,
    ConverseCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  new (
    input: ConverseCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    ConverseCommandInput,
    ConverseCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  getEndpointParameterInstructions(): import("@smithy/types").EndpointParameterInstructions;
};
export declare class ConverseCommand extends ConverseCommand_base {
  protected static __types: {
    api: {
      input: ConverseRequest;
      output: ConverseResponse;
    };
    sdk: {
      input: ConverseCommandInput;
      output: ConverseCommandOutput;
    };
  };
}
