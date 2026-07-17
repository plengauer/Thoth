import { MetadataBearer as __MetadataBearer } from "@smithy/types";
import {
  InvokeModelWithBidirectionalStreamRequest,
  InvokeModelWithBidirectionalStreamResponse,
} from "../models/models_0";
export { __MetadataBearer };
export interface InvokeModelWithBidirectionalStreamCommandInput extends InvokeModelWithBidirectionalStreamRequest {}
export interface InvokeModelWithBidirectionalStreamCommandOutput
  extends InvokeModelWithBidirectionalStreamResponse, __MetadataBearer {}
declare const InvokeModelWithBidirectionalStreamCommand_base: {
  new (
    input: InvokeModelWithBidirectionalStreamCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    InvokeModelWithBidirectionalStreamCommandInput,
    InvokeModelWithBidirectionalStreamCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  new (
    input: InvokeModelWithBidirectionalStreamCommandInput,
  ): import("@smithy/core/client").CommandImpl<
    InvokeModelWithBidirectionalStreamCommandInput,
    InvokeModelWithBidirectionalStreamCommandOutput,
    import("..").BedrockRuntimeClientResolvedConfig,
    import("..").ServiceInputTypes,
    import("..").ServiceOutputTypes
  >;
  getEndpointParameterInstructions(): import("@smithy/types").EndpointParameterInstructions;
};
export declare class InvokeModelWithBidirectionalStreamCommand extends InvokeModelWithBidirectionalStreamCommand_base {
  protected static __types: {
    api: {
      input: InvokeModelWithBidirectionalStreamRequest;
      output: InvokeModelWithBidirectionalStreamResponse;
    };
    sdk: {
      input: InvokeModelWithBidirectionalStreamCommandInput;
      output: InvokeModelWithBidirectionalStreamCommandOutput;
    };
  };
}
