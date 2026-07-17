/**
 * @internal
 */
export declare abstract class Retry {
    static v2026: boolean;
    static delay(): 50 | 100;
    static throttlingDelay(): 1000 | 500;
    static cost(): 5 | 14;
    static throttlingCost(): 5 | 10;
    static modifiedCostType(): "TRANSIENT" | "THROTTLING";
}
