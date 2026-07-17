"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.TLSAttributes = void 0;
/* The following attributes are not official, see open-telemetry/opentelemetry-specification#1652 */
var TLSAttributes;
(function (TLSAttributes) {
    TLSAttributes["PROTOCOL"] = "tls.protocol";
    TLSAttributes["AUTHORIZED"] = "tls.authorized";
    TLSAttributes["CIPHER_NAME"] = "tls.cipher.name";
    TLSAttributes["CIPHER_VERSION"] = "tls.cipher.version";
    TLSAttributes["CERTIFICATE_FINGERPRINT"] = "tls.certificate.fingerprint";
    TLSAttributes["CERTIFICATE_SERIAL_NUMBER"] = "tls.certificate.serialNumber";
    TLSAttributes["CERTIFICATE_VALID_FROM"] = "tls.certificate.validFrom";
    TLSAttributes["CERTIFICATE_VALID_TO"] = "tls.certificate.validTo";
    TLSAttributes["ALPN_PROTOCOL"] = "tls.alpnProtocol";
})(TLSAttributes = exports.TLSAttributes || (exports.TLSAttributes = {}));
//# sourceMappingURL=types.js.map