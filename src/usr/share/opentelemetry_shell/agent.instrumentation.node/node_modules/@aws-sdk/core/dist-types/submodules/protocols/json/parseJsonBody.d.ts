import type { HttpResponse, SerdeFunctions } from "@smithy/types";
/**
 * @internal
 */
export declare const parseJsonBody: (streamBody: any, context: SerdeFunctions) => any;
/**
 * @internal
 */
export declare const parseJsonErrorBody: (errorBody: any, context: SerdeFunctions) => Promise<any>;
/**
 * @internal
 */
export declare const loadRestJsonErrorCode: (output: HttpResponse, data: any) => string | undefined;
/**
 * @internal
 */
export declare const loadJsonRpcErrorCode: (output: HttpResponse, data: any, queryCompat?: boolean) => string | undefined;
