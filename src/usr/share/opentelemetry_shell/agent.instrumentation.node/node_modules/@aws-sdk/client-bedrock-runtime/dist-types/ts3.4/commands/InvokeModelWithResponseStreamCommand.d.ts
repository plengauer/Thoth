import { BlobPayloadInputTypes, MetadataBearer as __MetadataBearer } from "@smithy/types";
import {
  InvokeModelWithResponseStreamRequest,
  InvokeModelWithResponseStreamResponse,
} from "../models/models_0";
export { __MetadataBearer };
export type InvokeModelWithResponseStreamCommandInputType = Pick<
  InvokeModelWithResponseStreamRequest,
  Exclude<keyof InvokeModelWithResponseStreamRequest, "body">
> & {
  body?: BlobPayloadInputTypes;
};
export interface InvokeModelWithResponseStreamCommandInput extends InvokeModelWithResponseStreamCommandInputType {}
export interface InvokeModelWithResponseStreamCommandOutput
  extends InvokeModelWithResponseStreamResponse, __MetadataBearer {}
declare const InvokeModelWithResponseStreamCommand_base: {
  new (
    input: InvokeModelWithResponseStreamCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    InvokeModelWithResponseStreamCommandInput,
    InvokeModelWithResponseStreamCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  new (
    input: InvokeModelWithResponseStreamCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    InvokeModelWithResponseStreamCommandInput,
    InvokeModelWithResponseStreamCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  getEndpointParameterInstructions(): import("@smithy/types").EndpointParameterInstructions;
};
export declare class InvokeModelWithResponseStreamCommand extends InvokeModelWithResponseStreamCommand_base {
  protected static __types: {
    api: {
      input: InvokeModelWithResponseStreamRequest;
      output: InvokeModelWithResponseStreamResponse;
    };
    sdk: {
      input: InvokeModelWithResponseStreamCommandInput;
      output: InvokeModelWithResponseStreamCommandOutput;
    };
  };
}
