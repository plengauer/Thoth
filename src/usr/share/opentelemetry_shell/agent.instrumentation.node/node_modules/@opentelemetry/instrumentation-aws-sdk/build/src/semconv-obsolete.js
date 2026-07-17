"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.MESSAGING_OPERATION_VALUE_RECEIVE = exports.MESSAGING_DESTINATION_KIND_VALUE_TOPIC = exports.ATTR_MESSAGING_DESTINATION_KIND = exports.ATTR_MESSAGING_DESTINATION = exports.ATTR_FAAS_EXECUTION = void 0;
/*
 * This file contains constants for values that where replaced/removed from
 * Semantic Conventions long enough ago that they do not have `ATTR_*`
 * constants in the `@opentelemetry/semantic-conventions` package. Eventually
 * it is expected that this instrumention will be updated to emit telemetry
 * using modern Semantic Conventions, dropping the need for the constants in
 * this file.
 */
/**
 * The execution ID of the current function execution.
 *
 * @deprecated Use ATTR_FAAS_INVOCATION_ID in [incubating entry-point]({@link https://github.com/open-telemetry/opentelemetry-js/blob/main/semantic-conventions/README.md#unstable-semconv}).
 */
exports.ATTR_FAAS_EXECUTION = 'faas.execution';
/**
 * The message destination name. This might be equal to the span name but is required nevertheless.
 *
 * @deprecated Use ATTR_MESSAGING_DESTINATION_NAME in [incubating entry-point]({@link https://github.com/open-telemetry/opentelemetry-js/blob/main/semantic-conventions/README.md#unstable-semconv}).
 */
exports.ATTR_MESSAGING_DESTINATION = 'messaging.destination';
/**
 * The kind of message destination.
 *
 * @deprecated Removed in semconv v1.20.0.
 */
exports.ATTR_MESSAGING_DESTINATION_KIND = 'messaging.destination_kind';
/**
 * The kind of message destination.
 *
 * @deprecated Removed in semconv v1.20.0.
 */
exports.MESSAGING_DESTINATION_KIND_VALUE_TOPIC = 'topic';
/**
 * A string identifying the kind of message consumption as defined in the [Operation names](#operation-names) section above. If the operation is &#34;send&#34;, this attribute MUST NOT be set, since the operation can be inferred from the span kind in that case.
 *
 * @deprecated Use MESSAGING_OPERATION_TYPE_VALUE_RECEIVE in [incubating entry-point]({@link https://github.com/open-telemetry/opentelemetry-js/blob/main/semantic-conventions/README.md#unstable-semconv}).
 */
exports.MESSAGING_OPERATION_VALUE_RECEIVE = 'receive';
//# sourceMappingURL=semconv-obsolete.js.map