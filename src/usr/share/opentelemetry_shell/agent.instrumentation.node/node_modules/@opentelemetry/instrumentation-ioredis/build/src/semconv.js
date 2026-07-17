"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.DB_SYSTEM_VALUE_REDIS = exports.DB_SYSTEM_NAME_VALUE_REDIS = exports.ATTR_NET_PEER_PORT = exports.ATTR_NET_PEER_NAME = exports.ATTR_DB_SYSTEM = exports.ATTR_DB_STATEMENT = exports.ATTR_DB_CONNECTION_STRING = void 0;
/*
 * This file contains a copy of unstable semantic convention definitions
 * used by this package.
 * @see https://github.com/open-telemetry/opentelemetry-js/tree/main/semantic-conventions#unstable-semconv
 */
/**
 * Deprecated, use `server.address`, `server.port` attributes instead.
 *
 * @example "Server=(localdb)\\v11.0;Integrated Security=true;"
 *
 * @experimental This attribute is experimental and is subject to breaking changes in minor releases of `@opentelemetry/semantic-conventions`.
 *
 * @deprecated Replaced by `server.address` and `server.port`.
 */
exports.ATTR_DB_CONNECTION_STRING = 'db.connection_string';
/**
 * The database statement being executed.
 *
 * @example SELECT * FROM wuser_table
 * @example SET mykey "WuValue"
 *
 * @experimental This attribute is experimental and is subject to breaking changes in minor releases of `@opentelemetry/semantic-conventions`.
 *
 * @deprecated Replaced by `db.query.text`.
 */
exports.ATTR_DB_STATEMENT = 'db.statement';
/**
 * Deprecated, use `db.system.name` instead.
 *
 * @experimental This attribute is experimental and is subject to breaking changes in minor releases of `@opentelemetry/semantic-conventions`.
 *
 * @deprecated Replaced by `db.system.name`.
 */
exports.ATTR_DB_SYSTEM = 'db.system';
/**
 * Deprecated, use `server.address` on client spans and `client.address` on server spans.
 *
 * @example example.com
 *
 * @experimental This attribute is experimental and is subject to breaking changes in minor releases of `@opentelemetry/semantic-conventions`.
 *
 * @deprecated Replaced by `server.address` on client spans and `client.address` on server spans.
 */
exports.ATTR_NET_PEER_NAME = 'net.peer.name';
/**
 * Deprecated, use `server.port` on client spans and `client.port` on server spans.
 *
 * @example 8080
 *
 * @experimental This attribute is experimental and is subject to breaking changes in minor releases of `@opentelemetry/semantic-conventions`.
 *
 * @deprecated Replaced by `server.port` on client spans and `client.port` on server spans.
 */
exports.ATTR_NET_PEER_PORT = 'net.peer.port';
/**
 * Enum value "redis" for attribute {@link ATTR_DB_SYSTEM_NAME}.
 *
 * [Redis](https://redis.io/)
 *
 * @experimental This enum value is experimental and is subject to breaking changes in minor releases of `@opentelemetry/semantic-conventions`.
 */
exports.DB_SYSTEM_NAME_VALUE_REDIS = 'redis';
/**
 * Enum value "redis" for attribute {@link ATTR_DB_SYSTEM}.
 *
 * Redis
 *
 * @experimental This enum value is experimental and is subject to breaking changes in minor releases of `@opentelemetry/semantic-conventions`.
 */
exports.DB_SYSTEM_VALUE_REDIS = 'redis';
//# sourceMappingURL=semconv.js.map