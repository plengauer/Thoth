"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.V2_CONSTANTS = exports.V1_CONSTANTS = exports.MODULE_NAME = void 0;
exports.MODULE_NAME = 'router';
exports.V1_CONSTANTS = {
    requestHandlerName: 'handle_request',
    errorHandlerName: 'handle_error',
    routeFunctionBody: `function router(req, res, next) {
    router.handle(req, res, next)
  }`,
    handleFunctionBody: `function handle(req, res, next) {
    route.dispatch(req, res, next)
  }`,
};
exports.V2_CONSTANTS = {
    requestHandlerName: 'handleRequest',
    errorHandlerName: 'handleError',
    routeFunctionBody: `function router (req, res, next) {
    router.handle(req, res, next)
  }`,
    handleFunctionBody: `function handle (req, res, next) {
    route.dispatch(req, res, next)
  }`,
};
//# sourceMappingURL=constants.js.map