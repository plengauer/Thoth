"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.METRIC_DB_CLIENT_CONNECTIONS_USAGE = exports.DB_SYSTEM_VALUE_MONGODB = exports.DB_SYSTEM_NAME_VALUE_MONGODB = exports.ATTR_NET_PEER_PORT = exports.ATTR_NET_PEER_NAME = exports.ATTR_DB_SYSTEM = exports.ATTR_DB_STATEMENT = exports.ATTR_DB_OPERATION = exports.ATTR_DB_NAME = exports.ATTR_DB_MONGODB_COLLECTION = exports.ATTR_DB_CONNECTION_STRING = void 0;
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
 * Deprecated, use `db.collection.name` instead.
 *
 * @example "mytable"
 *
 * @experimental This attribute is experimental and is subject to breaking changes in minor releases of `@opentelemetry/semantic-conventions`.
 *
 * @deprecated Replaced by `db.collection.name`.
 */
exports.ATTR_DB_MONGODB_COLLECTION = 'db.mongodb.collection';
/**
 * Deprecated, use `db.namespace` instead.
 *
 * @example customers
 * @example main
 *
 * @experimental This attribute is experimental and is subject to breaking changes in minor releases of `@opentelemetry/semantic-conventions`.
 *
 * @deprecated Replaced by `db.namespace`.
 */
exports.ATTR_DB_NAME = 'db.name';
/**
 * Deprecated, use `db.operation.name` instead.
 *
 * @example findAndModify
 * @example HMSET
 * @example SELECT
 *
 * @experimental This attribute is experimental and is subject to breaking changes in minor releases of `@opentelemetry/semantic-conventions`.
 *
 * @deprecated Replaced by `db.operation.name`.
 */
exports.ATTR_DB_OPERATION = 'db.operation';
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
 * Enum value "mongodb" for attribute {@link ATTR_DB_SYSTEM_NAME}.
 *
 * [MongoDB](https://www.mongodb.com/)
 *
 * @experimental This enum value is experimental and is subject to breaking changes in minor releases of `@opentelemetry/semantic-conventions`.
 */
exports.DB_SYSTEM_NAME_VALUE_MONGODB = 'mongodb';
/**
 * Enum value "mongodb" for attribute {@link ATTR_DB_SYSTEM}.
 *
 * MongoDB
 *
 * @experimental This enum value is experimental and is subject to breaking changes in minor releases of `@opentelemetry/semantic-conventions`.
 */
exports.DB_SYSTEM_VALUE_MONGODB = 'mongodb';
/**
 * Deprecated, use `db.client.connection.count` instead.
 *
 * @experimental This metric is experimental and is subject to breaking changes in minor releases of `@opentelemetry/semantic-conventions`.
 *
 * @deprecated Replaced by `db.client.connection.count`.
 */
exports.METRIC_DB_CLIENT_CONNECTIONS_USAGE = 'db.client.connections.usage';
//# sourceMappingURL=semconv.js.map