/**
 * The message destination name. This might be equal to the span name but is required nevertheless.
 *
 * @deprecated Use ATTR_MESSAGING_DESTINATION_NAME in [incubating entry-point]({@link https://github.com/open-telemetry/opentelemetry-js/blob/main/semantic-conventions/README.md#unstable-semconv}).
 */
export declare const ATTR_MESSAGING_DESTINATION: "messaging.destination";
/**
 * The kind of message destination.
 *
 * @deprecated Removed in semconv v1.20.0.
 */
export declare const ATTR_MESSAGING_DESTINATION_KIND: "messaging.destination_kind";
/**
 * A string identifying the kind of message consumption as defined in the [Operation names](#operation-names) section above. If the operation is &#34;send&#34;, this attribute MUST NOT be set, since the operation can be inferred from the span kind in that case.
 *
 * @deprecated Use MESSAGING_OPERATION_TYPE_VALUE_RECEIVE in [incubating entry-point]({@link https://github.com/open-telemetry/opentelemetry-js/blob/main/semantic-conventions/README.md#unstable-semconv}).
 */
export declare const MESSAGING_OPERATION_VALUE_RECEIVE: "receive";
/**
 * The kind of message destination.
 *
 * @deprecated Removed in semconv v1.20.0.
 */
export declare const MESSAGING_DESTINATION_KIND_VALUE_TOPIC: "topic";
//# sourceMappingURL=semconv-obsolete.d.ts.map