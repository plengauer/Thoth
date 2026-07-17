"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.BaseCollector = void 0;
class BaseCollector {
    _config = {};
    constructor(config = {}) {
        this._config = config;
    }
    disable() {
        this._config.enabled = false;
        this.internalDisable();
    }
    enable() {
        this._config.enabled = true;
        this.internalEnable();
    }
}
exports.BaseCollector = BaseCollector;
//# sourceMappingURL=baseCollector.js.map