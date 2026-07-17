"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.azureVmDetector = exports.azureFunctionsDetector = exports.azureContainerAppsDetector = exports.azureAppServiceDetector = exports.azureAksDetector = void 0;
var AzureAksDetector_1 = require("./AzureAksDetector");
Object.defineProperty(exports, "azureAksDetector", { enumerable: true, get: function () { return AzureAksDetector_1.azureAksDetector; } });
var AzureAppServiceDetector_1 = require("./AzureAppServiceDetector");
Object.defineProperty(exports, "azureAppServiceDetector", { enumerable: true, get: function () { return AzureAppServiceDetector_1.azureAppServiceDetector; } });
var AzureContainerAppsDetector_1 = require("./AzureContainerAppsDetector");
Object.defineProperty(exports, "azureContainerAppsDetector", { enumerable: true, get: function () { return AzureContainerAppsDetector_1.azureContainerAppsDetector; } });
var AzureFunctionsDetector_1 = require("./AzureFunctionsDetector");
Object.defineProperty(exports, "azureFunctionsDetector", { enumerable: true, get: function () { return AzureFunctionsDetector_1.azureFunctionsDetector; } });
var AzureVmDetector_1 = require("./AzureVmDetector");
Object.defineProperty(exports, "azureVmDetector", { enumerable: true, get: function () { return AzureVmDetector_1.azureVmDetector; } });
//# sourceMappingURL=index.js.map