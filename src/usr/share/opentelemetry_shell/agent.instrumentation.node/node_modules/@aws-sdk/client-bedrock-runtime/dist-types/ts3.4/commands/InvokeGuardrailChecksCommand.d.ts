import { MetadataBearer as __MetadataBearer } from "@smithy/types";
import { InvokeGuardrailChecksRequest, InvokeGuardrailChecksResponse } from "../models/models_0";
export { __MetadataBearer };
export interface InvokeGuardrailChecksCommandInput extends InvokeGuardrailChecksRequest {}
export interface InvokeGuardrailChecksCommandOutput
  extends InvokeGuardrailChecksResponse, __MetadataBearer {}
declare const InvokeGuardrailChecksCommand_base: {
  new (
    input: InvokeGuardrailChecksCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    InvokeGuardrailChecksCommandInput,
    InvokeGuardrailChecksCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  new (
    input: InvokeGuardrailChecksCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    InvokeGuardrailChecksCommandInput,
    InvokeGuardrailChecksCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  getEndpointParameterInstructions(): import("@smithy/types").EndpointParameterInstructions;
};
export declare class InvokeGuardrailChecksCommand extends InvokeGuardrailChecksCommand_base {
  protected static __types: {
    api: {
      input: InvokeGuardrailChecksRequest;
      output: InvokeGuardrailChecksResponse;
    };
    sdk: {
      input: InvokeGuardrailChecksCommandInput;
      output: InvokeGuardrailChecksCommandOutput;
    };
  };
}
