"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.LruMemoizerInstrumentation = void 0;
const api_1 = require("@opentelemetry/api");
const instrumentation_1 = require("@opentelemetry/instrumentation");
/** @knipignore */
const version_1 = require("./version");
class LruMemoizerInstrumentation extends instrumentation_1.InstrumentationBase {
    constructor(config = {}) {
        super(version_1.PACKAGE_NAME, version_1.PACKAGE_VERSION, config);
    }
    init() {
        return [
            new instrumentation_1.InstrumentationNodeModuleDefinition('lru-memoizer', ['>=1.3 <4'], moduleExports => {
                // moduleExports is a function which receives an options object,
                // and returns a "memoizer" function upon invocation.
                // We want to patch this "memoizer's" internal function
                const asyncMemoizer = function () {
                    // This following function is invoked every time the user wants to get a (possible) memoized value
                    // We replace it with another function in which we bind the current context to the last argument (callback)
                    const origMemoizer = moduleExports.apply(this, arguments);
                    return function () {
                        const modifiedArguments = [...arguments];
                        // last argument is the callback
                        const origCallback = modifiedArguments.pop();
                        const callbackWithContext = typeof origCallback === 'function'
                            ? api_1.context.bind(api_1.context.active(), origCallback)
                            : origCallback;
                        modifiedArguments.push(callbackWithContext);
                        return origMemoizer.apply(this, modifiedArguments);
                    };
                };
                // sync function preserves context, but we still need to export it
                // as the lru-memoizer package does
                asyncMemoizer.sync = moduleExports.sync;
                return asyncMemoizer;
            }, undefined // no need to disable as this instrumentation does not create any spans
            ),
        ];
    }
}
exports.LruMemoizerInstrumentation = LruMemoizerInstrumentation;
//# sourceMappingURL=instrumentation.js.map