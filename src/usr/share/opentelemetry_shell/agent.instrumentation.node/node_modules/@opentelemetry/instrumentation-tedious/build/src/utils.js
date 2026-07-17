"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.once = exports.getSpanName = void 0;
/**
 * The span name SHOULD be set to a low cardinality value
 * representing the statement executed on the database.
 *
 * @returns Operation executed on Tedious Connection. Does not map to SQL statement in any way.
 */
function getSpanName(operation, db, sql, bulkLoadTable) {
    if (operation === 'execBulkLoad' && bulkLoadTable && db) {
        return `${operation} ${bulkLoadTable} ${db}`;
    }
    if (operation === 'callProcedure') {
        // `sql` refers to procedure name with `callProcedure`
        if (db) {
            return `${operation} ${sql} ${db}`;
        }
        return `${operation} ${sql}`;
    }
    // do not use `sql` in general case because of high-cardinality
    if (db) {
        return `${operation} ${db}`;
    }
    return `${operation}`;
}
exports.getSpanName = getSpanName;
const once = (fn) => {
    let called = false;
    return (...args) => {
        if (called)
            return;
        called = true;
        return fn(...args);
    };
};
exports.once = once;
//# sourceMappingURL=utils.js.map