import { MetadataBearer as __MetadataBearer } from "@smithy/types";
import { ApplyGuardrailRequest, ApplyGuardrailResponse } from "../models/models_0";
export { __MetadataBearer };
export interface ApplyGuardrailCommandInput extends ApplyGuardrailRequest {}
export interface ApplyGuardrailCommandOutput extends ApplyGuardrailResponse, __MetadataBearer {}
declare const ApplyGuardrailCommand_base: {
  new (
    input: ApplyGuardrailCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    ApplyGuardrailCommandInput,
    ApplyGuardrailCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  new (
    input: ApplyGuardrailCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    ApplyGuardrailCommandInput,
    ApplyGuardrailCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  getEndpointParameterInstructions(): import("@smithy/types").EndpointParameterInstructions;
};
export declare class ApplyGuardrailCommand extends ApplyGuardrailCommand_base {
  protected static __types: {
    api: {
      input: ApplyGuardrailRequest;
      output: ApplyGuardrailResponse;
    };
    sdk: {
      input: ApplyGuardrailCommandInput;
      output: ApplyGuardrailCommandOutput;
    };
  };
}
