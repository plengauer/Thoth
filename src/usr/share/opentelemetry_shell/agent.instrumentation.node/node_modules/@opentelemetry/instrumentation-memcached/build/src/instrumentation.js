"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.MemcachedInstrumentation = void 0;
const api = require("@opentelemetry/api");
const instrumentation_1 = require("@opentelemetry/instrumentation");
const semconv_1 = require("./semconv");
const semantic_conventions_1 = require("@opentelemetry/semantic-conventions");
const utils = require("./utils");
/** @knipignore */
const version_1 = require("./version");
class MemcachedInstrumentation extends instrumentation_1.InstrumentationBase {
    static COMPONENT = 'memcached';
    static DEFAULT_CONFIG = {
        enhancedDatabaseReporting: false,
    };
    _netSemconvStability;
    _dbSemconvStability;
    constructor(config = {}) {
        super(version_1.PACKAGE_NAME, version_1.PACKAGE_VERSION, {
            ...MemcachedInstrumentation.DEFAULT_CONFIG,
            ...config,
        });
        this._setSemconvStabilityFromEnv();
    }
    // Used for testing.
    _setSemconvStabilityFromEnv() {
        this._netSemconvStability = (0, instrumentation_1.semconvStabilityFromStr)('http', process.env.OTEL_SEMCONV_STABILITY_OPT_IN);
        this._dbSemconvStability = (0, instrumentation_1.semconvStabilityFromStr)('database', process.env.OTEL_SEMCONV_STABILITY_OPT_IN);
    }
    setConfig(config = {}) {
        super.setConfig({ ...MemcachedInstrumentation.DEFAULT_CONFIG, ...config });
    }
    init() {
        return [
            new instrumentation_1.InstrumentationNodeModuleDefinition('memcached', ['>=2.2.0 <3'], (moduleExports, moduleVersion) => {
                this.ensureWrapped(moduleExports.prototype, 'command', this.wrapCommand.bind(this, moduleVersion));
                return moduleExports;
            }, (moduleExports) => {
                if (moduleExports === undefined)
                    return;
                // `command` is documented API missing from the types
                this._unwrap(moduleExports.prototype, 'command');
            }),
        ];
    }
    wrapCommand(moduleVersion, original) {
        const instrumentation = this;
        return function (queryCompiler, server) {
            if (typeof queryCompiler !== 'function') {
                return original.apply(this, arguments);
            }
            const attributes = {
                'memcached.version': moduleVersion,
            };
            if (instrumentation._dbSemconvStability & instrumentation_1.SemconvStability.OLD) {
                attributes[semconv_1.ATTR_DB_SYSTEM] = semconv_1.DB_SYSTEM_VALUE_MEMCACHED;
            }
            if (instrumentation._dbSemconvStability & instrumentation_1.SemconvStability.STABLE) {
                attributes[semantic_conventions_1.ATTR_DB_SYSTEM_NAME] = semconv_1.DB_SYSTEM_NAME_VALUE_MEMCACHED;
            }
            // The name will be overwritten later
            const span = instrumentation.tracer.startSpan('unknown memcached command', {
                kind: api.SpanKind.CLIENT,
                attributes,
            });
            const parentContext = api.context.active();
            const context = api.trace.setSpan(parentContext, span);
            return api.context.with(context, original, this, instrumentation.wrapQueryCompiler.call(instrumentation, queryCompiler, this, server, parentContext, span), server);
        };
    }
    wrapQueryCompiler(original, client, server, callbackContext, span) {
        const instrumentation = this;
        return function () {
            const query = original.apply(this, arguments);
            const callback = query.callback;
            span.updateName(`memcached ${query.type}`);
            const attributes = {
                'db.memcached.key': query.key,
                'db.memcached.lifetime': query.lifetime,
                ...utils.getPeerAttributes(client, server, query, instrumentation._netSemconvStability),
            };
            if (instrumentation._dbSemconvStability & instrumentation_1.SemconvStability.OLD) {
                attributes[semconv_1.ATTR_DB_OPERATION] = query.type;
            }
            if (instrumentation._dbSemconvStability & instrumentation_1.SemconvStability.STABLE) {
                attributes[semantic_conventions_1.ATTR_DB_OPERATION_NAME] = query.type;
            }
            if (instrumentation.getConfig().enhancedDatabaseReporting) {
                if (instrumentation._dbSemconvStability & instrumentation_1.SemconvStability.OLD) {
                    attributes[semconv_1.ATTR_DB_STATEMENT] = query.command;
                }
                if (instrumentation._dbSemconvStability & instrumentation_1.SemconvStability.STABLE) {
                    attributes[semantic_conventions_1.ATTR_DB_QUERY_TEXT] = query.command;
                }
            }
            span.setAttributes(attributes);
            query.callback = api.context.bind(callbackContext, function (err) {
                if (err) {
                    span.recordException(err);
                    span.setStatus({
                        code: api.SpanStatusCode.ERROR,
                        message: err.message,
                    });
                }
                span.end();
                if (typeof callback === 'function') {
                    return callback.apply(this, arguments);
                }
            });
            return query;
        };
    }
    ensureWrapped(obj, methodName, wrapper) {
        if ((0, instrumentation_1.isWrapped)(obj[methodName])) {
            this._unwrap(obj, methodName);
        }
        this._wrap(obj, methodName, wrapper);
    }
}
exports.MemcachedInstrumentation = MemcachedInstrumentation;
//# sourceMappingURL=instrumentation.js.map