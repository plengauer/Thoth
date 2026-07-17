import { type ConditionObject, type EvaluateOptions } from "../types";
export declare const evaluateCondition: (condition: ConditionObject, options: EvaluateOptions) => {
    result: boolean;
    toAssign: {
        name: string;
        value: import("../types").FunctionReturn;
    };
} | {
    result: boolean;
    toAssign?: undefined;
};
