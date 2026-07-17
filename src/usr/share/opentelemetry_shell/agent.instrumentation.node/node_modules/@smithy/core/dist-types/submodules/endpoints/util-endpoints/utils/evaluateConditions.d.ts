import type { ConditionObject, EvaluateOptions, FunctionReturn } from "../types";
export declare const evaluateConditions: (conditions: ConditionObject[] | undefined, options: EvaluateOptions) => {
    result: boolean;
    referenceRecord: Record<string, FunctionReturn>;
} | {
    result: boolean;
    referenceRecord?: undefined;
};
