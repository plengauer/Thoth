"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.SUPPORTED_VERSIONS = exports.MODULE_NAME = void 0;
exports.MODULE_NAME = 'knex';
exports.SUPPORTED_VERSIONS = [
    // use "lib/execution" for runner.js, "lib" for client.js as basepath, latest tested 0.95.6
    '>=0.22.0 <4',
    // use "lib" as basepath
    '>=0.10.0 <0.18.0',
    '>=0.19.0 <0.22.0',
    // use "src" as basepath
    '>=0.18.0 <0.19.0',
];
//# sourceMappingURL=constants.js.map