import { type EvaluateOptions, type Expression, type FunctionObject, type FunctionReturn } from "../types";
export declare const evaluateExpression: (obj: Expression, keyName: string, options: EvaluateOptions) => FunctionReturn;
export declare const callFunction: ({ fn, argv }: FunctionObject, options: EvaluateOptions) => FunctionReturn;
export declare const group: {
    evaluateExpression: (obj: Expression, keyName: string, options: EvaluateOptions) => FunctionReturn;
    callFunction: ({ fn, argv }: FunctionObject, options: EvaluateOptions) => FunctionReturn;
};
