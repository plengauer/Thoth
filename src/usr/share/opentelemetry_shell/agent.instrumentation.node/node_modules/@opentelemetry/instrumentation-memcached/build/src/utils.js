"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.getPeerAttributes = void 0;
const semconv_1 = require("./semconv");
const semantic_conventions_1 = require("@opentelemetry/semantic-conventions");
const instrumentation_1 = require("@opentelemetry/instrumentation");
const getPeerAttributes = (client /* Memcached, but the type definitions are lacking */, server, query, netSemconvStability) => {
    if (!server) {
        if (client.servers.length === 1) {
            server = client.servers[0];
        }
        else {
            let redundancy = client.redundancy && client.redundancy < client.servers.length;
            const queryRedundancy = query.redundancyEnabled;
            if (redundancy && queryRedundancy) {
                redundancy = client.HashRing.range(query.key, client.redundancy + 1, true);
                server = redundancy.shift();
            }
            else {
                server = client.HashRing.get(query.key);
            }
        }
    }
    if (typeof server === 'string') {
        const [host, port] = server && server.split(':');
        if (host && port) {
            const portNumber = parseInt(port, 10);
            const attrs = {};
            if (netSemconvStability & instrumentation_1.SemconvStability.OLD) {
                attrs[semconv_1.ATTR_NET_PEER_NAME] = host;
                if (!isNaN(portNumber)) {
                    attrs[semconv_1.ATTR_NET_PEER_PORT] = portNumber;
                }
            }
            if (netSemconvStability & instrumentation_1.SemconvStability.STABLE) {
                attrs[semantic_conventions_1.ATTR_SERVER_ADDRESS] = host;
                if (!isNaN(portNumber)) {
                    attrs[semantic_conventions_1.ATTR_SERVER_PORT] = portNumber;
                }
            }
            return attrs;
        }
        if (host) {
            const attrs = {};
            if (netSemconvStability & instrumentation_1.SemconvStability.OLD) {
                attrs[semconv_1.ATTR_NET_PEER_NAME] = host;
            }
            if (netSemconvStability & instrumentation_1.SemconvStability.STABLE) {
                attrs[semantic_conventions_1.ATTR_SERVER_ADDRESS] = host;
            }
            return attrs;
        }
    }
    return {};
};
exports.getPeerAttributes = getPeerAttributes;
//# sourceMappingURL=utils.js.map