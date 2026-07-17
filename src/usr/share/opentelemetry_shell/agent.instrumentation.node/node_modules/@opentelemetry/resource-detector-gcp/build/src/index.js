"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.resetIsAvailableCache = exports.gcpDetector = void 0;
var detectors_1 = require("./detectors");
Object.defineProperty(exports, "gcpDetector", { enumerable: true, get: function () { return detectors_1.gcpDetector; } });
// Internal - used for tests only
var gcp_metadata_1 = require("gcp-metadata");
Object.defineProperty(exports, "resetIsAvailableCache", { enumerable: true, get: function () { return gcp_metadata_1.resetIsAvailableCache; } });
//# sourceMappingURL=index.js.map