"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * Copyright (c) 2025, Oracle and/or its affiliates.
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.OracleInstrumentation = void 0;
const instrumentation_1 = require("@opentelemetry/instrumentation");
const OracleTelemetryTraceHandler_1 = require("./OracleTelemetryTraceHandler");
/** @knipignore */
const version_1 = require("./version");
class OracleInstrumentation extends instrumentation_1.InstrumentationBase {
    _tmHandler;
    constructor(config = {}) {
        super(version_1.PACKAGE_NAME, version_1.PACKAGE_VERSION, config);
    }
    init() {
        const moduleOracleDB = new instrumentation_1.InstrumentationNodeModuleDefinition('oracledb', ['>= 6.7 < 7'], (moduleExports) => {
            if (!moduleExports) {
                return;
            }
            if (this._tmHandler) {
                // Already registered, so unregister it.
                moduleExports.traceHandler.setTraceInstance();
                this._tmHandler = null;
            }
            const config = this.getConfig();
            const thClass = (0, OracleTelemetryTraceHandler_1.getOracleTelemetryTraceHandlerClass)(moduleExports);
            if (thClass) {
                const obj = new thClass(() => this.tracer, config);
                obj.enable();
                // Register the instance with oracledb.
                moduleExports.traceHandler.setTraceInstance(obj);
                this._tmHandler = obj;
            }
            return moduleExports;
        }, moduleExports => {
            if (this._tmHandler) {
                moduleExports.traceHandler.setTraceInstance();
                this._tmHandler = null;
            }
        });
        return [moduleOracleDB];
    }
    setConfig(config = {}) {
        super.setConfig(config);
        // update the config in OracleTelemetryTraceHandler obj.
        this._tmHandler?.setInstrumentConfig(this._config);
    }
}
exports.OracleInstrumentation = OracleInstrumentation;
//# sourceMappingURL=instrumentation.js.map