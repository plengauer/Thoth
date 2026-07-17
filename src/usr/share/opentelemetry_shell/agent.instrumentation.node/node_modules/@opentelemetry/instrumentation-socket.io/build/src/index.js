"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.defaultSocketIoPath = exports.SocketIoInstrumentationAttributes = exports.SocketIoInstrumentation = void 0;
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
var socket_io_1 = require("./socket.io");
Object.defineProperty(exports, "SocketIoInstrumentation", { enumerable: true, get: function () { return socket_io_1.SocketIoInstrumentation; } });
var AttributeNames_1 = require("./AttributeNames");
Object.defineProperty(exports, "SocketIoInstrumentationAttributes", { enumerable: true, get: function () { return AttributeNames_1.SocketIoInstrumentationAttributes; } });
var types_1 = require("./types");
Object.defineProperty(exports, "defaultSocketIoPath", { enumerable: true, get: function () { return types_1.defaultSocketIoPath; } });
//# sourceMappingURL=index.js.map