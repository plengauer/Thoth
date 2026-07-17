"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AttributeNames = void 0;
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
// Postgresql specific attributes not covered by semantic conventions
var AttributeNames;
(function (AttributeNames) {
    AttributeNames["PG_VALUES"] = "db.postgresql.values";
    AttributeNames["PG_PLAN"] = "db.postgresql.plan";
    AttributeNames["IDLE_TIMEOUT_MILLIS"] = "db.postgresql.idle.timeout.millis";
    AttributeNames["MAX_CLIENT"] = "db.postgresql.max.client";
})(AttributeNames = exports.AttributeNames || (exports.AttributeNames = {}));
//# sourceMappingURL=AttributeNames.js.map