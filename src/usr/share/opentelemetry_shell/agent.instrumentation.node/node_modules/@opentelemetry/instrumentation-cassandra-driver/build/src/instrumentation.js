"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.CassandraDriverInstrumentation = void 0;
const api_1 = require("@opentelemetry/api");
const instrumentation_1 = require("@opentelemetry/instrumentation");
const semconv_1 = require("./semconv");
const semantic_conventions_1 = require("@opentelemetry/semantic-conventions");
/** @knipignore */
const version_1 = require("./version");
const supportedVersions = ['>=4.4.0 <5'];
class CassandraDriverInstrumentation extends instrumentation_1.InstrumentationBase {
    _netSemconvStability;
    _dbSemconvStability;
    constructor(config = {}) {
        super(version_1.PACKAGE_NAME, version_1.PACKAGE_VERSION, config);
        this._setSemconvStabilityFromEnv();
    }
    _setSemconvStabilityFromEnv() {
        this._netSemconvStability = (0, instrumentation_1.semconvStabilityFromStr)('http', process.env.OTEL_SEMCONV_STABILITY_OPT_IN);
        this._dbSemconvStability = (0, instrumentation_1.semconvStabilityFromStr)('database', process.env.OTEL_SEMCONV_STABILITY_OPT_IN);
    }
    init() {
        return new instrumentation_1.InstrumentationNodeModuleDefinition('cassandra-driver', supportedVersions, driverModule => {
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            const Client = driverModule.Client.prototype;
            if ((0, instrumentation_1.isWrapped)(Client['_execute'])) {
                this._unwrap(Client, '_execute');
            }
            if ((0, instrumentation_1.isWrapped)(Client.batch)) {
                this._unwrap(Client, 'batch');
            }
            if ((0, instrumentation_1.isWrapped)(Client.stream)) {
                this._unwrap(Client, 'stream');
            }
            this._wrap(Client, '_execute', this._getPatchedExecute());
            this._wrap(Client, 'batch', this._getPatchedBatch());
            this._wrap(Client, 'stream', this._getPatchedStream());
            return driverModule;
        }, driverModule => {
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            const Client = driverModule.Client.prototype;
            if ((0, instrumentation_1.isWrapped)(Client['_execute'])) {
                this._unwrap(Client, '_execute');
            }
            if ((0, instrumentation_1.isWrapped)(Client.batch)) {
                this._unwrap(Client, 'batch');
            }
            if ((0, instrumentation_1.isWrapped)(Client.stream)) {
                this._unwrap(Client, 'stream');
            }
        }, [
            new instrumentation_1.InstrumentationNodeModuleFile('cassandra-driver/lib/request-execution.js', supportedVersions, execution => {
                if ((0, instrumentation_1.isWrapped)(execution.prototype['_sendOnConnection'])) {
                    this._unwrap(execution.prototype, '_sendOnConnection');
                }
                this._wrap(execution.prototype, '_sendOnConnection', this._getPatchedSendOnConnection());
                return execution;
            }, execution => {
                if (execution === undefined)
                    return;
                this._unwrap(execution.prototype, '_sendOnConnection');
            }),
        ]);
    }
    _getMaxQueryLength() {
        return this.getConfig().maxQueryLength ?? 65536;
    }
    _shouldIncludeDbStatement() {
        return this.getConfig().enhancedDatabaseReporting ?? false;
    }
    _getPatchedExecute() {
        return (original) => {
            const plugin = this;
            return function patchedExecute(...args) {
                const span = plugin.startSpan({ op: 'execute', query: args[0] }, this);
                const execContext = api_1.trace.setSpan(api_1.context.active(), span);
                const execPromise = (0, instrumentation_1.safeExecuteInTheMiddle)(() => {
                    return api_1.context.with(execContext, () => {
                        return original.apply(this, args);
                    });
                }, error => {
                    if (error) {
                        failSpan(span, error);
                    }
                });
                const wrappedPromise = wrapPromise(span, execPromise, (span, result) => {
                    plugin._callResponseHook(span, result);
                });
                return api_1.context.bind(execContext, wrappedPromise);
            };
        };
    }
    _getPatchedSendOnConnection() {
        return (original) => {
            const plugin = this;
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            return function patchedSendOnConnection(...args) {
                const span = api_1.trace.getSpan(api_1.context.active());
                const conn = this['_connection'];
                if (span !== undefined && conn !== undefined) {
                    const port = parseInt(conn.port, 10);
                    if (plugin._netSemconvStability & instrumentation_1.SemconvStability.OLD) {
                        span.setAttribute(semconv_1.ATTR_NET_PEER_NAME, conn.address);
                        if (!isNaN(port)) {
                            span.setAttribute(semconv_1.ATTR_NET_PEER_PORT, port);
                        }
                    }
                    if (plugin._netSemconvStability & instrumentation_1.SemconvStability.STABLE) {
                        span.setAttribute(semantic_conventions_1.ATTR_SERVER_ADDRESS, conn.address);
                        if (!isNaN(port)) {
                            span.setAttribute(semantic_conventions_1.ATTR_SERVER_PORT, port);
                        }
                    }
                }
                return original.apply(this, args);
            };
        };
    }
    _getPatchedBatch() {
        return (original) => {
            const plugin = this;
            return function patchedBatch(...args) {
                const queries = Array.isArray(args[0]) ? args[0] : [];
                const span = plugin.startSpan({ op: 'batch', query: combineQueries(queries) }, this);
                const batchContext = api_1.trace.setSpan(api_1.context.active(), span);
                if (typeof args[args.length - 1] === 'function') {
                    const originalCallback = args[args.length - 1];
                    const patchedCallback = function (...cbArgs) {
                        const error = cbArgs[0];
                        if (error) {
                            span.setStatus({
                                code: api_1.SpanStatusCode.ERROR,
                                message: error.message,
                            });
                            span.recordException(error);
                        }
                        span.end();
                        return originalCallback.apply(this, cbArgs);
                    };
                    args[args.length - 1] = patchedCallback;
                    return api_1.context.with(batchContext, () => {
                        return original.apply(this, args);
                    });
                }
                const batchPromise = (0, instrumentation_1.safeExecuteInTheMiddle)(() => {
                    return api_1.context.with(batchContext, () => {
                        return original.apply(this, args);
                    });
                }, error => {
                    if (error) {
                        failSpan(span, error);
                    }
                });
                const wrappedPromise = wrapPromise(span, batchPromise);
                return api_1.context.bind(batchContext, wrappedPromise);
            };
        };
    }
    _getPatchedStream() {
        return (original) => {
            const plugin = this;
            return function patchedStream(...args) {
                // Since stream internally uses execute, there is no need to add DB_STATEMENT twice
                const span = plugin.startSpan({ op: 'stream' }, this);
                const callback = args[3];
                const endSpan = (error) => {
                    if (error) {
                        span.setStatus({
                            code: api_1.SpanStatusCode.ERROR,
                            message: error.message,
                        });
                        span.recordException(error);
                    }
                    span.end();
                };
                if (callback === undefined) {
                    args[3] = endSpan;
                }
                else if (typeof callback === 'function') {
                    const wrappedCallback = function (err) {
                        endSpan(err);
                        return callback.call(this, err);
                    };
                    args[3] = wrappedCallback;
                }
                const streamContext = api_1.trace.setSpan(api_1.context.active(), span);
                return (0, instrumentation_1.safeExecuteInTheMiddle)(() => {
                    return api_1.context.with(streamContext, () => {
                        return original.apply(this, args);
                    });
                }, error => {
                    if (error) {
                        failSpan(span, error);
                    }
                });
            };
        };
    }
    startSpan({ op, query }, client) {
        const attributes = {};
        if (this._dbSemconvStability & instrumentation_1.SemconvStability.OLD) {
            attributes[semconv_1.ATTR_DB_SYSTEM] = semconv_1.DB_SYSTEM_VALUE_CASSANDRA;
        }
        if (this._dbSemconvStability & instrumentation_1.SemconvStability.STABLE) {
            attributes[semantic_conventions_1.ATTR_DB_SYSTEM_NAME] = semconv_1.DB_SYSTEM_NAME_VALUE_CASSANDRA;
        }
        if (this._shouldIncludeDbStatement() && query !== undefined) {
            const statement = truncateQuery(query, this._getMaxQueryLength());
            if (this._dbSemconvStability & instrumentation_1.SemconvStability.OLD) {
                attributes[semconv_1.ATTR_DB_STATEMENT] = statement;
            }
            if (this._dbSemconvStability & instrumentation_1.SemconvStability.STABLE) {
                attributes[semantic_conventions_1.ATTR_DB_QUERY_TEXT] = statement;
            }
        }
        // db.user (deprecated, no stable replacement - only emit with OLD)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const user = client.options?.credentials?.username;
        if (user && this._dbSemconvStability & instrumentation_1.SemconvStability.OLD) {
            attributes[semconv_1.ATTR_DB_USER] = user;
        }
        if (client.keyspace) {
            if (this._dbSemconvStability & instrumentation_1.SemconvStability.OLD) {
                attributes[semconv_1.ATTR_DB_NAME] = client.keyspace;
            }
            if (this._dbSemconvStability & instrumentation_1.SemconvStability.STABLE) {
                attributes[semantic_conventions_1.ATTR_DB_NAMESPACE] = client.keyspace;
            }
        }
        return this.tracer.startSpan(`cassandra-driver.${op}`, {
            kind: api_1.SpanKind.CLIENT,
            attributes,
        });
    }
    _callResponseHook(span, response) {
        const { responseHook } = this.getConfig();
        if (!responseHook) {
            return;
        }
        (0, instrumentation_1.safeExecuteInTheMiddle)(() => responseHook(span, { response: response }), e => {
            if (e) {
                this._diag.error('responseHook error', e);
            }
        }, true);
    }
}
exports.CassandraDriverInstrumentation = CassandraDriverInstrumentation;
function failSpan(span, error) {
    span.setStatus({
        code: api_1.SpanStatusCode.ERROR,
        message: error.message,
    });
    span.recordException(error);
    span.end();
}
function combineQueries(queries) {
    return queries
        .map(query => (typeof query === 'string' ? query : query.query))
        .join('\n');
}
function wrapPromise(span, promise, successCallback) {
    return promise
        .then(result => {
        return new Promise(resolve => {
            if (successCallback) {
                successCallback(span, result);
            }
            span.end();
            resolve(result);
        });
    })
        .catch((error) => {
        return new Promise((_, reject) => {
            span.setStatus({
                code: api_1.SpanStatusCode.ERROR,
                message: error.message,
            });
            span.recordException(error);
            span.end();
            reject(error);
        });
    });
}
function truncateQuery(query, maxQueryLength) {
    return String(query).substring(0, maxQueryLength);
}
//# sourceMappingURL=instrumentation.js.map