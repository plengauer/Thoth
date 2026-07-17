import { Uint8ArrayBlobAdapter } from "@smithy/core/serde";
import { BlobPayloadInputTypes, MetadataBearer as __MetadataBearer } from "@smithy/types";
import { InvokeModelRequest, InvokeModelResponse } from "../models/models_0";
export { __MetadataBearer };
export type InvokeModelCommandInputType = Pick<
  InvokeModelRequest,
  Exclude<keyof InvokeModelRequest, "body">
> & {
  body?: BlobPayloadInputTypes;
};
export interface InvokeModelCommandInput extends InvokeModelCommandInputType {}
export type InvokeModelCommandOutputType = Pick<
  InvokeModelResponse,
  Exclude<keyof InvokeModelResponse, "body">
> & {
  body: Uint8ArrayBlobAdapter;
};
export interface InvokeModelCommandOutput extends InvokeModelCommandOutputType, __MetadataBearer {}
declare const InvokeModelCommand_base: {
  new (
    input: InvokeModelCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    InvokeModelCommandInput,
    InvokeModelCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  new (
    input: InvokeModelCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    InvokeModelCommandInput,
    InvokeModelCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  getEndpointParameterInstructions(): import("@smithy/types").EndpointParameterInstructions;
};
export declare class InvokeModelCommand extends InvokeModelCommand_base {
  protected static __types: {
    api: {
      input: InvokeModelRequest;
      output: InvokeModelResponse;
    };
    sdk: {
      input: InvokeModelCommandInput;
      output: InvokeModelCommandOutput;
    };
  };
}
