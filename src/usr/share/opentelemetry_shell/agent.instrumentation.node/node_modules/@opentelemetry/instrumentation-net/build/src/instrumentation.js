"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.NetInstrumentation = void 0;
const api_1 = require("@opentelemetry/api");
const instrumentation_1 = require("@opentelemetry/instrumentation");
const semantic_conventions_1 = require("@opentelemetry/semantic-conventions");
const semconv_1 = require("./semconv");
const types_1 = require("./types");
const internal_types_1 = require("./internal-types");
const utils_1 = require("./utils");
/** @knipignore */
const version_1 = require("./version");
const tls_1 = require("tls");
class NetInstrumentation extends instrumentation_1.InstrumentationBase {
    _netSemconvStability;
    constructor(config = {}) {
        super(version_1.PACKAGE_NAME, version_1.PACKAGE_VERSION, config);
        this._setSemconvStabilityFromEnv();
    }
    // Used for testing.
    _setSemconvStabilityFromEnv() {
        this._netSemconvStability = (0, instrumentation_1.semconvStabilityFromStr)('http', process.env.OTEL_SEMCONV_STABILITY_OPT_IN);
    }
    init() {
        return [
            new instrumentation_1.InstrumentationNodeModuleDefinition('net', ['*'], (moduleExports) => {
                if ((0, instrumentation_1.isWrapped)(moduleExports.Socket.prototype.connect)) {
                    this._unwrap(moduleExports.Socket.prototype, 'connect');
                }
                this._wrap(moduleExports.Socket.prototype, 'connect', 
                // eslint-disable-next-line @typescript-eslint/no-explicit-any
                this._getPatchedConnect());
                return moduleExports;
            }, (moduleExports) => {
                if (moduleExports === undefined)
                    return;
                this._unwrap(moduleExports.Socket.prototype, 'connect');
            }),
        ];
    }
    _getPatchedConnect() {
        return (original) => {
            const plugin = this;
            return function patchedConnect(...args) {
                const options = (0, utils_1.getNormalizedArgs)(args);
                const span = this instanceof tls_1.TLSSocket
                    ? plugin._startTLSSpan(options, this)
                    : plugin._startSpan(options, this);
                return (0, instrumentation_1.safeExecuteInTheMiddle)(() => original.apply(this, args), error => {
                    if (error !== undefined) {
                        span.setStatus({
                            code: api_1.SpanStatusCode.ERROR,
                            message: error.message,
                        });
                        span.recordException(error);
                        span.end();
                    }
                });
            };
        };
    }
    _startSpan(options, socket) {
        if (!options) {
            return this._startGenericSpan(socket);
        }
        if (options.path) {
            return this._startIpcSpan(options, socket);
        }
        return this._startTcpSpan(options, socket);
    }
    _startTLSSpan(options, socket) {
        const tlsSpan = this.tracer.startSpan('tls.connect');
        const netSpan = api_1.context.with(api_1.trace.setSpan(api_1.context.active(), tlsSpan), () => {
            return this._startSpan(options, socket);
        });
        const otelTlsSpanListener = () => {
            const peerCertificate = socket.getPeerCertificate(true);
            const cipher = socket.getCipher();
            const protocol = socket.getProtocol();
            const attributes = {
                [types_1.TLSAttributes.PROTOCOL]: String(protocol),
                [types_1.TLSAttributes.AUTHORIZED]: String(socket.authorized),
                [types_1.TLSAttributes.CIPHER_NAME]: cipher.name,
                [types_1.TLSAttributes.CIPHER_VERSION]: cipher.version,
                [types_1.TLSAttributes.CERTIFICATE_FINGERPRINT]: peerCertificate.fingerprint,
                [types_1.TLSAttributes.CERTIFICATE_SERIAL_NUMBER]: peerCertificate.serialNumber,
                [types_1.TLSAttributes.CERTIFICATE_VALID_FROM]: peerCertificate.valid_from,
                [types_1.TLSAttributes.CERTIFICATE_VALID_TO]: peerCertificate.valid_to,
                [types_1.TLSAttributes.ALPN_PROTOCOL]: '',
            };
            if (socket.alpnProtocol) {
                attributes[types_1.TLSAttributes.ALPN_PROTOCOL] = socket.alpnProtocol;
            }
            tlsSpan.setAttributes(attributes);
            tlsSpan.end();
        };
        const otelTlsErrorListener = (e) => {
            tlsSpan.setStatus({
                code: api_1.SpanStatusCode.ERROR,
                message: e.message,
            });
            tlsSpan.end();
        };
        /* if we use once and tls.connect() uses a callback this is never executed */
        socket.prependOnceListener(internal_types_1.SocketEvent.SECURE_CONNECT, otelTlsSpanListener);
        socket.once(internal_types_1.SocketEvent.ERROR, otelTlsErrorListener);
        const otelTlsRemoveListeners = () => {
            socket.removeListener(internal_types_1.SocketEvent.SECURE_CONNECT, otelTlsSpanListener);
            socket.removeListener(internal_types_1.SocketEvent.ERROR, otelTlsErrorListener);
            for (const event of SOCKET_EVENTS) {
                socket.removeListener(event, otelTlsRemoveListeners);
            }
        };
        for (const event of [
            internal_types_1.SocketEvent.CLOSE,
            internal_types_1.SocketEvent.ERROR,
            internal_types_1.SocketEvent.SECURE_CONNECT,
        ]) {
            socket.once(event, otelTlsRemoveListeners);
        }
        return netSpan;
    }
    /* It might still be useful to pick up errors due to invalid connect arguments. */
    _startGenericSpan(socket) {
        const span = this.tracer.startSpan('connect');
        registerListeners(socket, span, false, this._netSemconvStability);
        return span;
    }
    _startIpcSpan(options, socket) {
        const attributes = {};
        if (this._netSemconvStability & instrumentation_1.SemconvStability.OLD) {
            attributes[semconv_1.ATTR_NET_TRANSPORT] = utils_1.OLD_IPC_TRANSPORT_VALUE;
            attributes[semconv_1.ATTR_NET_PEER_NAME] = options.path;
        }
        if (this._netSemconvStability & instrumentation_1.SemconvStability.STABLE) {
            attributes[semantic_conventions_1.ATTR_NETWORK_TRANSPORT] = utils_1.STABLE_IPC_TRANSPORT_VALUE;
            attributes[semantic_conventions_1.ATTR_SERVER_ADDRESS] = options.path;
        }
        const span = this.tracer.startSpan('ipc.connect', { attributes });
        registerListeners(socket, span, false, this._netSemconvStability);
        return span;
    }
    _startTcpSpan(options, socket) {
        const attributes = {};
        if (this._netSemconvStability & instrumentation_1.SemconvStability.OLD) {
            attributes[semconv_1.ATTR_NET_TRANSPORT] = semconv_1.NET_TRANSPORT_VALUE_IP_TCP;
            attributes[semconv_1.ATTR_NET_PEER_NAME] = options.host;
            attributes[semconv_1.ATTR_NET_PEER_PORT] = options.port;
        }
        if (this._netSemconvStability & instrumentation_1.SemconvStability.STABLE) {
            attributes[semantic_conventions_1.ATTR_NETWORK_TRANSPORT] = semantic_conventions_1.NETWORK_TRANSPORT_VALUE_TCP;
            attributes[semantic_conventions_1.ATTR_SERVER_ADDRESS] = options.host;
            attributes[semantic_conventions_1.ATTR_SERVER_PORT] = options.port;
        }
        const span = this.tracer.startSpan('tcp.connect', { attributes });
        registerListeners(socket, span, true, this._netSemconvStability);
        return span;
    }
}
exports.NetInstrumentation = NetInstrumentation;
const SOCKET_EVENTS = [
    internal_types_1.SocketEvent.CLOSE,
    internal_types_1.SocketEvent.CONNECT,
    internal_types_1.SocketEvent.ERROR,
];
function spanEndHandler(span) {
    return () => {
        span.end();
    };
}
function spanErrorHandler(span) {
    return (e) => {
        span.setStatus({
            code: api_1.SpanStatusCode.ERROR,
            message: e.message,
        });
    };
}
function registerListeners(socket, span, hostAttributes, netSemconvStability) {
    const setSpanError = spanErrorHandler(span);
    const setSpanEnd = spanEndHandler(span);
    const setHostAttributes = () => {
        const attributes = {};
        if (netSemconvStability & instrumentation_1.SemconvStability.OLD) {
            attributes[semconv_1.ATTR_NET_PEER_IP] = socket.remoteAddress;
            attributes[semconv_1.ATTR_NET_HOST_IP] = socket.localAddress;
            attributes[semconv_1.ATTR_NET_HOST_PORT] = socket.localPort;
        }
        if (netSemconvStability & instrumentation_1.SemconvStability.STABLE) {
            attributes[semantic_conventions_1.ATTR_NETWORK_PEER_ADDRESS] = socket.remoteAddress;
            attributes[semantic_conventions_1.ATTR_NETWORK_LOCAL_ADDRESS] = socket.localAddress;
            attributes[semantic_conventions_1.ATTR_NETWORK_LOCAL_PORT] = socket.localPort;
        }
        span.setAttributes(attributes);
    };
    socket.once(internal_types_1.SocketEvent.ERROR, setSpanError);
    if (hostAttributes) {
        socket.once(internal_types_1.SocketEvent.CONNECT, setHostAttributes);
    }
    const removeListeners = () => {
        socket.removeListener(internal_types_1.SocketEvent.ERROR, setSpanError);
        socket.removeListener(internal_types_1.SocketEvent.CONNECT, setHostAttributes);
        for (const event of SOCKET_EVENTS) {
            socket.removeListener(event, setSpanEnd);
            socket.removeListener(event, removeListeners);
        }
    };
    for (const event of SOCKET_EVENTS) {
        socket.once(event, setSpanEnd);
        socket.once(event, removeListeners);
    }
}
//# sourceMappingURL=instrumentation.js.map