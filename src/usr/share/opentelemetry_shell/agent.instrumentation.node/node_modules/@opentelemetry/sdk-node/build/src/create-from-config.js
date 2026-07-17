"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.createSpanLimitsFromConfig = void 0;
function createSpanLimitsFromConfig(limits, attribute_limits) {
    if (!limits && !attribute_limits) {
        return undefined;
    }
    return {
        attributeValueLengthLimit: limits?.attribute_value_length_limit ??
            attribute_limits?.attribute_value_length_limit ??
            undefined,
        attributeCountLimit: limits?.attribute_count_limit ??
            attribute_limits?.attribute_count_limit ??
            undefined,
        eventCountLimit: limits?.event_count_limit ?? undefined,
        linkCountLimit: limits?.link_count_limit ?? undefined,
        attributePerEventCountLimit: limits?.event_attribute_count_limit ?? undefined,
        attributePerLinkCountLimit: limits?.link_attribute_count_limit ?? undefined,
    };
}
exports.createSpanLimitsFromConfig = createSpanLimitsFromConfig;
//# sourceMappingURL=create-from-config.js.map