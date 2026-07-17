const { nv, NumericValue, calculateBodyLength, _parseEpochTimestamp, fromBase64, generateIdempotencyToken } = require("@smithy/core/serde");
const { HttpRequest, collectBody, SerdeContext, RpcProtocol } = require("@smithy/core/protocols");
const { NormalizedSchema, deref, TypeRegistry } = require("@smithy/core/schema");
const { getSmithyContext } = require("@smithy/core/transport");

const majorUint64 = 0;
const majorNegativeInt64 = 1;
const majorUnstructuredByteString = 2;
const majorUtf8String = 3;
const majorList = 4;
const majorMap = 5;
const majorTag = 6;
const majorSpecial = 7;
const specialFalse = 20;
const specialTrue = 21;
const specialNull = 22;
const specialUndefined = 23;
const extendedOneByte = 24;
const extendedFloat16 = 25;
const extendedFloat32 = 26;
const extendedFloat64 = 27;
const minorIndefinite = 31;
function alloc(size) {
    return typeof Buffer !== "undefined" ? Buffer.alloc(size) : new Uint8Array(size);
}
const tagSymbol = Symbol("@smithy/core/cbor::tagSymbol");
function tag(data) {
    data[tagSymbol] = true;
    return data;
}

const USE_BUFFER$1 = typeof Buffer !== "undefined";
const textDecoder = new TextDecoder();
let payload = alloc(0);
let isBuffer = false;
let dataView$1 = new DataView(payload.buffer, payload.byteOffset, payload.byteLength);
let _offset = 0;
function setPayload(bytes) {
    payload = bytes;
    isBuffer = USE_BUFFER$1 && payload instanceof Buffer;
    dataView$1 = new DataView(payload.buffer, payload.byteOffset, payload.byteLength);
}
function decode(at, to) {
    if (at >= to) {
        throw new Error("unexpected end of (decode) payload.");
    }
    const major = (payload[at] & 0b1110_0000) >> 5;
    const minor = payload[at] & 0b0001_1111;
    if (minor === minorIndefinite && 2 <= major && major <= 5) {
        return decodeIndefinite(at, to);
    }
    switch (major) {
        case majorUint64:
        case majorNegativeInt64:
        case majorTag: {
            let unsignedInt;
            let offset;
            if (minor < 24) {
                unsignedInt = minor;
                offset = 1;
            }
            else {
                switch (minor) {
                    case extendedOneByte:
                        if (to - at < 2) {
                            overflow(1);
                        }
                        unsignedInt = payload[at + 1];
                        offset = 2;
                        break;
                    case extendedFloat16:
                        if (to - at < 3) {
                            overflow(2);
                        }
                        unsignedInt = dataView$1.getUint16(at + 1);
                        offset = 3;
                        break;
                    case extendedFloat32:
                        if (to - at < 5) {
                            overflow(4);
                        }
                        unsignedInt = dataView$1.getUint32(at + 1);
                        offset = 5;
                        break;
                    case extendedFloat64:
                        if (to - at < 9) {
                            overflow(8);
                        }
                        {
                            const hi = dataView$1.getUint32(at + 1);
                            if (hi < 0x00200000) {
                                unsignedInt = hi * 4294967296 + dataView$1.getUint32(at + 5);
                            }
                            else {
                                unsignedInt = dataView$1.getBigUint64(at + 1);
                            }
                        }
                        offset = 9;
                        break;
                    default:
                        unexpectedMinor(minor);
                }
            }
            if (major === majorUint64) {
                _offset = offset;
                return castBigInt(unsignedInt);
            }
            else if (major === majorNegativeInt64) {
                let negativeInt;
                if (typeof unsignedInt === "bigint") {
                    negativeInt = BigInt(-1) - unsignedInt;
                }
                else {
                    negativeInt = -1 - unsignedInt;
                }
                _offset = offset;
                return castBigInt(negativeInt);
            }
            else {
                return decodeTagValue(at, to, minor, unsignedInt, offset);
            }
        }
        case majorUtf8String:
            return decodeUtf8String(at, to);
        case majorMap:
            return decodeMap(at, to);
        case majorList:
            return decodeList(at, to);
        case majorUnstructuredByteString:
            return decodeUnstructuredByteString(at, to);
        default:
            return decodeSpecial(at, to);
    }
}
function decodeIndefinite(at, to) {
    const major = (payload[at] & 0b1110_0000) >> 5;
    const minor = payload[at] & 0b0001_1111;
    if (minor === minorIndefinite) {
        switch (major) {
            case majorUtf8String:
                return decodeUtf8StringIndefinite(at, to);
            case majorMap:
                return decodeMapIndefinite(at, to);
            case majorList:
                return decodeListIndefinite(at, to);
            case majorUnstructuredByteString:
                return decodeUnstructuredByteStringIndefinite(at, to);
        }
    }
}
function bytesToFloat16(a, b) {
    const sign = a >> 7;
    const exponent = (a & 0b0111_1100) >> 2;
    const fraction = ((a & 0b0000_0011) << 8) | b;
    const scalar = sign === 0 ? 1 : -1;
    if (exponent === 0b00000) {
        if (fraction === 0) {
            return 0;
        }
        return scalar * (Math.pow(2, 1 - 15) * (fraction / 1024));
    }
    else if (exponent === 0b11111) {
        if (fraction === 0) {
            return scalar * Infinity;
        }
        return NaN;
    }
    return scalar * (Math.pow(2, exponent - 15) * (1 + fraction / 1024));
}
function decodeMap(at, to) {
    const mapDataLength = decodeCount(at, to);
    if (mapDataLength < 15) {
        return decodeMapSmall(at, to, mapDataLength);
    }
    return decodeMapLarge(at, to, mapDataLength);
}
function decodeMapLarge(at, to, mapDataLength) {
    const offset = _offset;
    at += offset;
    const base = at;
    const map = Object.create(null);
    for (let i = 0; i < mapDataLength; ++i) {
        const key = decodeUtf8String(at, to);
        at += _offset;
        const valMajor = (payload[at] & 0b1110_0000) >> 5;
        if (valMajor === majorUtf8String) {
            map[key] = decodeUtf8String(at, to);
        }
        else {
            map[key] = decode(at, to);
        }
        at += _offset;
    }
    _offset = offset + (at - base);
    Object.setPrototypeOf(map, Object.prototype);
    return map;
}
function decodeMapSmall(at, to, mapDataLength) {
    const offset = _offset;
    at += offset;
    const base = at;
    const map = {};
    for (let i = 0; i < mapDataLength; ++i) {
        const key = decodeUtf8String(at, to);
        at += _offset;
        map[key] = decode(at, to);
        at += _offset;
    }
    _offset = offset + (at - base);
    return map;
}
function decodeList(at, to) {
    const listDataLength = decodeCount(at, to);
    const offset = _offset;
    at += offset;
    const base = at;
    const list = Array(listDataLength);
    for (let i = 0; i < listDataLength; ++i) {
        list[i] = decode(at, to);
        at += _offset;
    }
    _offset = offset + (at - base);
    return list;
}
function decodeUtf8String(at, to) {
    const length = decodeCount(at, to);
    const offset = _offset;
    at += offset;
    if (to - at < length) {
        overflow(length);
    }
    _offset = offset + length;
    if (length < 24) {
        return decodeUtf8StringCached(at, length);
    }
    if (isBuffer) {
        return payload.toString("utf-8", at, at + length);
    }
    return textDecoder.decode(payload.subarray(at, at + length));
}
const stringCache = new Array(2048);
const stringCacheEpochs = new Uint16Array(2048);
let cacheEpoch = 0;
function advanceDecodingEpoch() {
    cacheEpoch = (cacheEpoch + 1) & 0b1111_1111_1111_1111;
}
function decodeUtf8StringCached(at, length) {
    let h = length;
    for (let i = 0; i < length; ++i) {
        h = (h * 31 + payload[at + i]) | 0;
    }
    const slot = (h >>> 0) & 2047;
    const cached = stringCache[slot];
    if (cached !== undefined) {
        if (cached.length === length) {
            let match = true;
            for (let i = 0; i < length; ++i) {
                if (cached.charCodeAt(i) !== payload[at + i]) {
                    match = false;
                    break;
                }
            }
            if (match) {
                stringCacheEpochs[slot] = cacheEpoch;
                return cached;
            }
        }
    }
    const result = isBuffer
        ? payload.toString("utf-8", at, at + length)
        : textDecoder.decode(payload.subarray(at, at + length));
    if (stringCacheEpochs[slot] !== cacheEpoch) {
        stringCache[slot] = result;
        stringCacheEpochs[slot] = cacheEpoch;
    }
    return result;
}
function decodeUnstructuredByteString(at, to) {
    const length = decodeCount(at, to);
    const offset = _offset;
    at += offset;
    if (to - at < length) {
        overflow(length);
    }
    const value = payload.subarray(at, at + length);
    _offset = offset + length;
    return value;
}
function decodeTagValue(at, to, minor, unsignedInt, offset) {
    if (minor === 2 || minor === 3) {
        const length = decodeCount(at + offset, to);
        let b = BigInt(0);
        const start = at + offset + _offset;
        for (let i = start; i < start + length; ++i) {
            b = (b << BigInt(8)) | BigInt(payload[i]);
        }
        _offset = offset + _offset + length;
        return minor === 3 ? -b - BigInt(1) : b;
    }
    else if (minor === 4) {
        const decimalFraction = decode(at + offset, to);
        const [exponent, mantissa] = decimalFraction;
        const normalizer = mantissa < 0 ? -1 : 1;
        const mantissaStr = "0".repeat(Math.abs(exponent) + 1) + String(BigInt(normalizer) * BigInt(mantissa));
        let numericString;
        const sign = mantissa < 0 ? "-" : "";
        numericString =
            exponent === 0
                ? mantissaStr
                : mantissaStr.slice(0, mantissaStr.length + exponent) + "." + mantissaStr.slice(exponent);
        numericString = numericString.replace(/^0+/g, "");
        if (numericString === "") {
            numericString = "0";
        }
        if (numericString[0] === ".") {
            numericString = "0" + numericString;
        }
        numericString = sign + numericString;
        _offset = offset + _offset;
        return nv(numericString);
    }
    else {
        const value = decode(at + offset, to);
        const valueOffset = _offset;
        _offset = offset + valueOffset;
        return tag({ tag: castBigInt(unsignedInt), value });
    }
}
function decodeSpecial(at, to) {
    const minor = payload[at] & 0b0001_1111;
    switch (minor) {
        case specialTrue:
        case specialFalse:
            _offset = 1;
            return minor === specialTrue;
        case specialNull:
            _offset = 1;
            return null;
        case specialUndefined:
            _offset = 1;
            return null;
        case extendedFloat16:
            if (to - at < 3) {
                throw new Error("incomplete float16 at end of buf.");
            }
            _offset = 3;
            return bytesToFloat16(payload[at + 1], payload[at + 2]);
        case extendedFloat32:
            if (to - at < 5) {
                throw new Error("incomplete float32 at end of buf.");
            }
            _offset = 5;
            return dataView$1.getFloat32(at + 1);
        case extendedFloat64:
            if (to - at < 9) {
                throw new Error("incomplete float64 at end of buf.");
            }
            _offset = 9;
            return dataView$1.getFloat64(at + 1);
        default:
            unexpectedMinor(minor);
    }
}
function decodeCount(at, to) {
    const minor = payload[at] & 0b0001_1111;
    if (minor < 24) {
        _offset = 1;
        return minor;
    }
    switch (minor) {
        case extendedOneByte:
            if (to - at < 2) {
                overflow(1);
            }
            _offset = 2;
            return payload[at + 1];
        case extendedFloat16:
            if (to - at < 3) {
                overflow(2);
            }
            _offset = 3;
            return dataView$1.getUint16(at + 1);
        case extendedFloat32:
            if (to - at < 5) {
                overflow(4);
            }
            _offset = 5;
            return dataView$1.getUint32(at + 1);
        case extendedFloat64:
            if (to - at < 9) {
                overflow(8);
            }
            _offset = 9;
            return demote(dataView$1.getBigUint64(at + 1));
        default:
            unexpectedMinor(minor);
    }
}
function decodeMapIndefinite(at, to) {
    at += 1;
    const base = at;
    const map = {};
    for (; at < to;) {
        if (payload[at] === 0b1111_1111) {
            _offset = at - base + 2;
            return map;
        }
        const key = decodeUtf8String(at, to);
        at += _offset;
        map[key] = decode(at, to);
        at += _offset;
    }
    throw new Error("expected break marker.");
}
function decodeListIndefinite(at, to) {
    at += 1;
    const list = [];
    for (const base = at; at < to;) {
        if (payload[at] === 0b1111_1111) {
            _offset = at - base + 2;
            return list;
        }
        list.push(decode(at, to));
        at += _offset;
    }
    throw new Error("expected break marker.");
}
function decodeUtf8StringIndefinite(at, to) {
    at += 1;
    const vector = [];
    for (const base = at; at < to;) {
        if (payload[at] === 0b1111_1111) {
            const data = alloc(vector.length);
            data.set(vector, 0);
            _offset = at - base + 2;
            if (USE_BUFFER$1) {
                return data.toString("utf-8", 0, data.length);
            }
            return textDecoder.decode(data);
        }
        const major = (payload[at] & 0b1110_0000) >> 5;
        const minor = payload[at] & 0b0001_1111;
        if (major !== majorUtf8String) {
            unexpectedMajorInIndefiniteString(major);
        }
        if (minor === minorIndefinite) {
            throw new Error("nested indefinite string.");
        }
        const bytes = decodeUnstructuredByteString(at, to);
        const length = _offset;
        at += length;
        for (let i = 0; i < bytes.length; ++i) {
            vector.push(bytes[i]);
        }
    }
    throw new Error("expected break marker.");
}
function decodeUnstructuredByteStringIndefinite(at, to) {
    at += 1;
    const vector = [];
    for (const base = at; at < to;) {
        if (payload[at] === 0b1111_1111) {
            const data = alloc(vector.length);
            data.set(vector, 0);
            _offset = at - base + 2;
            return data;
        }
        const major = (payload[at] & 0b1110_0000) >> 5;
        const minor = payload[at] & 0b0001_1111;
        if (major !== majorUnstructuredByteString) {
            unexpectedMajorInIndefiniteString(major);
        }
        if (minor === minorIndefinite) {
            throw new Error("nested indefinite string.");
        }
        const bytes = decodeUnstructuredByteString(at, to);
        const length = _offset;
        at += length;
        for (let i = 0; i < bytes.length; ++i) {
            vector.push(bytes[i]);
        }
    }
    throw new Error("expected break marker.");
}
function castBigInt(bigInt) {
    if (typeof bigInt === "number") {
        return bigInt;
    }
    const num = Number(bigInt);
    if (Number.MIN_SAFE_INTEGER <= num && num <= Number.MAX_SAFE_INTEGER) {
        return num;
    }
    return bigInt;
}
function demote(bigInteger) {
    const num = Number(bigInteger);
    if (num < Number.MIN_SAFE_INTEGER || Number.MAX_SAFE_INTEGER < num) {
        console.warn(new Error(`@smithy/core/cbor - truncating BigInt(${bigInteger}) to ${num} with loss of precision.`));
    }
    return num;
}
function overflow(n) {
    throw new Error(`length ${n} greater than remaining buf len.`);
}
function unexpectedMinor(minor) {
    throw new Error(`unexpected minor value ${minor}.`);
}
function unexpectedMajorInIndefiniteString(major) {
    throw new Error(`unexpected major type ${major} in indefinite string.`);
}

const USE_BUFFER = typeof Buffer !== "undefined";
const encodeStringCache = new Map();
let encodeCacheEpoch = 0;
let encodeCacheSaturated = false;
const initialSize = 2048;
let data = alloc(initialSize);
let dataView = new DataView(data.buffer, data.byteOffset, data.byteLength);
let cursor = 0;
function encode(_input) {
    const encodeStack = [_input];
    while (encodeStack.length) {
        const input = encodeStack.pop();
        if (typeof input === "string") {
            const len = input.length;
            if (USE_BUFFER) {
                ensureSpace(len * 3 + 9);
                if (len > 23) {
                    encodeHeader(majorUtf8String, Buffer.byteLength(input));
                    cursor += data.write(input, cursor);
                }
                else {
                    encodeStringCached(input);
                }
            }
            else {
                const maxBytes = len * 3;
                ensureSpace(maxBytes + 9);
                const headerPos = cursor;
                const result = new TextEncoder().encodeInto(input, data.subarray(cursor + 9));
                const byteLen = result.written;
                let headerSize;
                if (byteLen < 24) {
                    headerSize = 1;
                }
                else if (byteLen < 256) {
                    headerSize = 2;
                }
                else if (byteLen < 65536) {
                    headerSize = 3;
                }
                else if (byteLen < 4294967296) {
                    headerSize = 5;
                }
                else {
                    headerSize = 9;
                }
                if (headerSize < 9) {
                    data.copyWithin(headerPos + headerSize, headerPos + 9, headerPos + 9 + byteLen);
                }
                cursor = headerPos;
                encodeInteger(majorUtf8String, byteLen);
                cursor += byteLen;
            }
            continue;
        }
        if (data.byteLength - cursor < 9) {
            ensureSpace(64);
        }
        if (typeof input === "number") {
            if (Number.isInteger(input)) {
                const nonNegative = input >= 0;
                const major = nonNegative ? majorUint64 : majorNegativeInt64;
                const value = nonNegative ? input : -input - 1;
                if (value < 24) {
                    data[cursor++] = (major << 5) | value;
                }
                else if (value < 256) {
                    data[cursor++] = (major << 5) | 24;
                    data[cursor++] = value;
                }
                else if (value < 65536) {
                    data[cursor++] = (major << 5) | extendedFloat16;
                    data[cursor++] = value >> 8;
                    data[cursor++] = value & 0xff;
                }
                else if (value < 4294967296) {
                    data[cursor++] = (major << 5) | extendedFloat32;
                    dataView.setUint32(cursor, value);
                    cursor += 4;
                }
                else {
                    data[cursor++] = (major << 5) | extendedFloat64;
                    const hi = (value / 4294967296) | 0;
                    const lo = (value - hi * 4294967296) | 0;
                    dataView.setUint32(cursor, hi);
                    dataView.setUint32(cursor + 4, lo);
                    cursor += 8;
                }
                continue;
            }
            data[cursor++] = (majorSpecial << 5) | extendedFloat64;
            dataView.setFloat64(cursor, input);
            cursor += 8;
            continue;
        }
        else if (typeof input === "bigint") {
            const nonNegative = input >= 0;
            const major = nonNegative ? majorUint64 : majorNegativeInt64;
            const value = nonNegative ? input : -input - BigInt(1);
            if (value < BigInt("18446744073709551616")) {
                const n = Number(value);
                if (n < 4294967296) {
                    encodeInteger(major, n);
                }
                else {
                    data[cursor++] = (major << 5) | extendedFloat64;
                    dataView.setBigUint64(cursor, value);
                    cursor += 8;
                }
            }
            else {
                const binaryBigInt = value.toString(2);
                const bigIntBytes = new Uint8Array(Math.ceil(binaryBigInt.length / 8));
                let b = value;
                let i = 0;
                while (bigIntBytes.byteLength - ++i >= 0) {
                    bigIntBytes[bigIntBytes.byteLength - i] = Number(b & BigInt(255));
                    b >>= BigInt(8);
                }
                ensureSpace(bigIntBytes.byteLength * 2 + 16);
                data[cursor++] = nonNegative ? 0b110_00010 : 0b110_00011;
                encodeHeader(majorUnstructuredByteString, bigIntBytes.byteLength);
                data.set(bigIntBytes, cursor);
                cursor += bigIntBytes.byteLength;
            }
            continue;
        }
        else if (input === null) {
            data[cursor++] = (majorSpecial << 5) | specialNull;
            continue;
        }
        else if (typeof input === "boolean") {
            data[cursor++] = (majorSpecial << 5) | (input ? specialTrue : specialFalse);
            continue;
        }
        else if (typeof input === "undefined") {
            throw new Error("@smithy/core/cbor: client may not serialize undefined value.");
        }
        else if (Array.isArray(input)) {
            encodeInteger(majorList, input.length);
            ensureSpace(input.length * 9 + 64);
            for (let i = input.length - 1; i >= 0; --i) {
                encodeStack.push(input[i]);
            }
            continue;
        }
        else if (typeof input.byteLength === "number") {
            ensureSpace(input.length * 2 + 9);
            encodeInteger(majorUnstructuredByteString, input.length);
            data.set(input, cursor);
            cursor += input.byteLength;
            continue;
        }
        else if (typeof input === "object") {
            if (input instanceof NumericValue) {
                const decimalIndex = input.string.indexOf(".");
                const exponent = decimalIndex === -1 ? 0 : decimalIndex - input.string.length + 1;
                const mantissa = BigInt(input.string.replace(".", ""));
                data[cursor++] = 0b110_00100;
                encodeInteger(majorList, 2);
                encodeStack.push(mantissa);
                encodeStack.push(exponent);
                continue;
            }
            if (input[tagSymbol]) {
                if ("tag" in input && "value" in input) {
                    encodeStack.push(input.value);
                    encodeHeader(majorTag, input.tag);
                    continue;
                }
                else {
                    throw new Error("tag encountered with missing fields, need 'tag' and 'value', found: " + JSON.stringify(input));
                }
            }
            const keys = Object.keys(input);
            const len = keys.length;
            encodeInteger(majorMap, len);
            for (let i = len - 1; i >= 0; --i) {
                encodeStack.push(input[keys[i]]);
                encodeStack.push(keys[i]);
            }
            continue;
        }
        throw new Error(`data type ${input?.constructor?.name ?? typeof input} not compatible for encoding.`);
    }
}
function advanceEncodingEpoch() {
    encodeCacheEpoch = (encodeCacheEpoch + 1) & 0b1111_1111_1111_1111;
    encodeCacheSaturated = false;
}
function toUint8Array() {
    const out = alloc(cursor);
    out.set(data.subarray(0, cursor), 0);
    cursor = 0;
    return out;
}
function resize(size) {
    const old = data;
    data = alloc(size);
    if (old) {
        if (old.copy) {
            old.copy(data, 0, 0, old.byteLength);
        }
        else {
            data.set(old, 0);
        }
    }
    dataView = new DataView(data.buffer, data.byteOffset, data.byteLength);
}
function encodeStringCached(input) {
    const cached = encodeStringCache.get(input);
    if (cached !== undefined) {
        data.set(cached.bytes, cursor);
        cursor += cached.bytes.length;
        cached.epoch = encodeCacheEpoch;
        return;
    }
    const start = cursor;
    const byteLen = Buffer.byteLength(input);
    encodeInteger(majorUtf8String, byteLen);
    cursor += data.write(input, cursor);
    const bytes = Uint8Array.prototype.slice.call(data, start, cursor);
    if (encodeStringCache.size >= 2048) {
        if (encodeCacheSaturated) {
            return;
        }
        let evicted = 0;
        for (const [key, entry] of encodeStringCache) {
            if (evicted >= 1024) {
                break;
            }
            if (entry.epoch !== encodeCacheEpoch) {
                encodeStringCache.delete(key);
                evicted++;
            }
        }
        if (evicted === 0) {
            encodeCacheSaturated = true;
            return;
        }
    }
    if (encodeStringCache.size < 2048) {
        encodeStringCache.set(input, { epoch: encodeCacheEpoch, bytes });
    }
}
function ensureSpace(bytes) {
    const remaining = data.byteLength - cursor;
    if (remaining < bytes) {
        if (cursor < 16_000_000) {
            resize(Math.max(data.byteLength * 4, data.byteLength + bytes));
        }
        else {
            resize(data.byteLength + bytes + 16_000_000);
        }
    }
}
function encodeHeader(major, value) {
    if (value < 24) {
        data[cursor++] = (major << 5) | value;
    }
    else if (value < 256) {
        data[cursor++] = (major << 5) | 24;
        data[cursor++] = value;
    }
    else if (value < 65536) {
        data[cursor++] = (major << 5) | extendedFloat16;
        dataView.setUint16(cursor, value);
        cursor += 2;
    }
    else if (value < 4294967296) {
        data[cursor++] = (major << 5) | extendedFloat32;
        dataView.setUint32(cursor, value);
        cursor += 4;
    }
    else {
        data[cursor++] = (major << 5) | extendedFloat64;
        dataView.setBigUint64(cursor, typeof value === "bigint" ? value : BigInt(value));
        cursor += 8;
    }
}
function encodeInteger(major, value) {
    if (value < 24) {
        data[cursor++] = (major << 5) | value;
    }
    else if (value < 256) {
        data[cursor++] = (major << 5) | 24;
        data[cursor++] = value;
    }
    else if (value < 65536) {
        data[cursor++] = (major << 5) | extendedFloat16;
        data[cursor++] = value >> 8;
        data[cursor++] = value & 0xff;
    }
    else if (value < 4294967296) {
        data[cursor++] = (major << 5) | extendedFloat32;
        dataView.setUint32(cursor, value);
        cursor += 4;
    }
    else {
        data[cursor++] = (major << 5) | extendedFloat64;
        const hi = (value / 4294967296) | 0;
        const lo = (value - hi * 4294967296) | 0;
        dataView.setUint32(cursor, hi);
        dataView.setUint32(cursor + 4, lo);
        cursor += 8;
    }
}

const cbor = {
    deserialize(payload) {
        advanceDecodingEpoch();
        setPayload(payload);
        return decode(0, payload.length);
    },
    serialize(input) {
        advanceEncodingEpoch();
        try {
            encode(input);
            return toUint8Array();
        }
        catch (e) {
            toUint8Array();
            throw e;
        }
    },
    resizeEncodingBuffer(size) {
        resize(size);
    },
};

const parseCborBody = (streamBody, context) => {
    return collectBody(streamBody, context).then(async (bytes) => {
        if (bytes.length) {
            try {
                return cbor.deserialize(bytes);
            }
            catch (e) {
                Object.defineProperty(e, "$responseBodyText", {
                    value: context.utf8Encoder(bytes),
                });
                throw e;
            }
        }
        return {};
    });
};
const dateToTag = (date) => {
    return tag({
        tag: 1,
        value: date.getTime() / 1000,
    });
};
const parseCborErrorBody = async (errorBody, context) => {
    const value = await parseCborBody(errorBody, context);
    value.message = value.message ?? value.Message;
    return value;
};
const loadSmithyRpcV2CborErrorCode = (output, data) => {
    const sanitizeErrorCode = (rawValue) => {
        let cleanValue = rawValue;
        if (typeof cleanValue === "number") {
            cleanValue = cleanValue.toString();
        }
        if (cleanValue.indexOf(",") >= 0) {
            cleanValue = cleanValue.split(",")[0];
        }
        if (cleanValue.indexOf(":") >= 0) {
            cleanValue = cleanValue.split(":")[0];
        }
        if (cleanValue.indexOf("#") >= 0) {
            cleanValue = cleanValue.split("#")[1];
        }
        return cleanValue;
    };
    if (data["__type"] !== undefined) {
        return sanitizeErrorCode(data["__type"]);
    }
    let codeKey;
    for (const key in data) {
        if (key.toLowerCase() === "code") {
            codeKey = key;
            break;
        }
    }
    if (codeKey && data[codeKey] !== undefined) {
        return sanitizeErrorCode(data[codeKey]);
    }
};
const checkCborResponse = (response) => {
    if (String(response.headers["smithy-protocol"]).toLowerCase() !== "rpc-v2-cbor") {
        throw new Error("Malformed RPCv2 CBOR response, status: " + response.statusCode);
    }
};
const buildHttpRpcRequest = async (context, headers, path, resolvedHostname, body) => {
    const endpoint = await context.endpoint();
    const { hostname, protocol = "https", port, path: basePath } = endpoint;
    const contents = {
        protocol,
        hostname,
        port,
        method: "POST",
        path: basePath.endsWith("/") ? basePath.slice(0, -1) + path : basePath + path,
        headers: {
            ...headers,
        },
    };
    if (resolvedHostname !== undefined) {
        contents.hostname = resolvedHostname;
    }
    if (endpoint.headers) {
        for (const name in endpoint.headers) {
            contents.headers[name] = endpoint.headers[name];
        }
    }
    if (body !== undefined) {
        contents.body = body;
        try {
            contents.headers["content-length"] = String(calculateBodyLength(body));
        }
        catch (ignored) { }
    }
    return new HttpRequest(contents);
};

class CborCodec extends SerdeContext {
    createSerializer() {
        const serializer = new CborShapeSerializer();
        serializer.setSerdeContext(this.serdeContext);
        return serializer;
    }
    createDeserializer() {
        const deserializer = new CborShapeDeserializer();
        deserializer.setSerdeContext(this.serdeContext);
        return deserializer;
    }
}
class CborShapeSerializer extends SerdeContext {
    value;
    write(schema, value) {
        this.value = this.serialize(schema, value);
    }
    serialize(schema, source) {
        const ns = NormalizedSchema.of(schema);
        if (source == null) {
            if (ns.isIdempotencyToken()) {
                return generateIdempotencyToken();
            }
            return source;
        }
        if (ns.isBlobSchema()) {
            if (typeof source === "string") {
                return (this.serdeContext?.base64Decoder ?? fromBase64)(source);
            }
            return source;
        }
        if (ns.isTimestampSchema()) {
            if (typeof source === "number" || typeof source === "bigint") {
                return dateToTag(new Date((Number(source) / 1000) | 0));
            }
            return dateToTag(source);
        }
        if (typeof source === "function" || typeof source === "object") {
            const sourceObject = source;
            if (ns.isListSchema() && Array.isArray(sourceObject)) {
                const sparse = !!ns.getMergedTraits().sparse;
                const newArray = [];
                let i = 0;
                for (const item of sourceObject) {
                    const value = this.serialize(ns.getValueSchema(), item);
                    if (value != null || sparse) {
                        newArray[i++] = value;
                    }
                }
                return newArray;
            }
            if (sourceObject instanceof Date) {
                return dateToTag(sourceObject);
            }
            const newObject = {};
            if (ns.isMapSchema()) {
                const sparse = !!ns.getMergedTraits().sparse;
                for (const key in sourceObject) {
                    const value = this.serialize(ns.getValueSchema(), sourceObject[key]);
                    if (value != null || sparse) {
                        newObject[key] = value;
                    }
                }
            }
            else if (ns.isStructSchema()) {
                for (const [key, memberSchema] of ns.structIterator()) {
                    const value = this.serialize(memberSchema, sourceObject[key]);
                    if (value != null) {
                        newObject[key] = value;
                    }
                }
                const isUnion = ns.isUnionSchema();
                if (isUnion && Array.isArray(sourceObject.$unknown)) {
                    const [k, v] = sourceObject.$unknown;
                    newObject[k] = v;
                }
                else if (typeof sourceObject.__type === "string") {
                    for (const k in sourceObject) {
                        if (!(k in newObject)) {
                            newObject[k] = this.serialize(15, sourceObject[k]);
                        }
                    }
                }
            }
            else if (ns.isDocumentSchema()) {
                for (const key in sourceObject) {
                    newObject[key] = this.serialize(ns.getValueSchema(), sourceObject[key]);
                }
            }
            else if (ns.isBigDecimalSchema()) {
                return sourceObject;
            }
            return newObject;
        }
        return source;
    }
    flush() {
        const buffer = cbor.serialize(this.value);
        this.value = undefined;
        return buffer;
    }
}
class CborShapeDeserializer extends SerdeContext {
    read(schema, bytes) {
        const data = cbor.deserialize(bytes);
        return this.readValue(schema, data);
    }
    readValue(_schema, value) {
        const ns = NormalizedSchema.of(_schema);
        if (ns.isTimestampSchema()) {
            if (typeof value === "number") {
                return _parseEpochTimestamp(value);
            }
            if (typeof value === "object") {
                if (value.tag === 1 && "value" in value) {
                    return _parseEpochTimestamp(value.value);
                }
            }
        }
        if (ns.isBlobSchema()) {
            if (typeof value === "string") {
                return (this.serdeContext?.base64Decoder ?? fromBase64)(value);
            }
            return value;
        }
        if (typeof value === "undefined" ||
            typeof value === "boolean" ||
            typeof value === "number" ||
            typeof value === "string" ||
            typeof value === "bigint" ||
            typeof value === "symbol") {
            return value;
        }
        else if (typeof value === "object") {
            if (value === null) {
                return null;
            }
            if ("byteLength" in value) {
                return value;
            }
            if (value instanceof Date) {
                return value;
            }
            if (ns.isDocumentSchema()) {
                return value;
            }
            if (ns.isListSchema()) {
                const newArray = [];
                const memberSchema = ns.getValueSchema();
                for (const item of value) {
                    const itemValue = this.readValue(memberSchema, item);
                    newArray.push(itemValue);
                }
                return newArray;
            }
            const newObject = {};
            if (ns.isMapSchema()) {
                const targetSchema = ns.getValueSchema();
                for (const key in value) {
                    const itemValue = this.readValue(targetSchema, value[key]);
                    newObject[key] = itemValue;
                }
            }
            else if (ns.isStructSchema()) {
                const isUnion = ns.isUnionSchema();
                let keys;
                if (isUnion) {
                    keys = new Set();
                    for (const k in value) {
                        if (k !== "__type") {
                            keys.add(k);
                        }
                    }
                }
                for (const [key, memberSchema] of ns.structIterator()) {
                    if (isUnion) {
                        keys.delete(key);
                    }
                    if (value[key] != null) {
                        newObject[key] = this.readValue(memberSchema, value[key]);
                    }
                }
                if (isUnion && keys?.size === 1) {
                    let newObjectEmpty = true;
                    for (const _ in newObject) {
                        newObjectEmpty = false;
                        break;
                    }
                    if (newObjectEmpty) {
                        const k = keys.values().next().value;
                        newObject.$unknown = [k, value[k]];
                    }
                }
                else if (typeof value.__type === "string") {
                    for (const k in value) {
                        if (!(k in newObject)) {
                            newObject[k] = value[k];
                        }
                    }
                }
            }
            else if (value instanceof NumericValue) {
                return value;
            }
            return newObject;
        }
        else {
            return value;
        }
    }
}

class SmithyRpcV2CborProtocol extends RpcProtocol {
    codec = new CborCodec();
    serializer = this.codec.createSerializer();
    deserializer = this.codec.createDeserializer();
    constructor({ defaultNamespace, errorTypeRegistries, }) {
        super({ defaultNamespace, errorTypeRegistries });
    }
    getShapeId() {
        return "smithy.protocols#rpcv2Cbor";
    }
    getPayloadCodec() {
        return this.codec;
    }
    async serializeRequest(operationSchema, input, context) {
        const request = await super.serializeRequest(operationSchema, input, context);
        Object.assign(request.headers, {
            "content-type": this.getDefaultContentType(),
            "smithy-protocol": "rpc-v2-cbor",
            accept: this.getDefaultContentType(),
        });
        if (deref(operationSchema.input) === "unit") {
            delete request.body;
            delete request.headers["content-type"];
        }
        else {
            if (!request.body) {
                this.serializer.write(15, {});
                request.body = this.serializer.flush();
            }
            try {
                request.headers["content-length"] = String(request.body.byteLength);
            }
            catch (ignored) { }
        }
        const { service, operation } = getSmithyContext(context);
        const path = `/service/${service}/operation/${operation}`;
        if (request.path.endsWith("/")) {
            request.path += path.slice(1);
        }
        else {
            request.path += path;
        }
        return request;
    }
    async deserializeResponse(operationSchema, context, response) {
        return super.deserializeResponse(operationSchema, context, response);
    }
    async handleError(operationSchema, context, response, dataObject, metadata) {
        const errorName = loadSmithyRpcV2CborErrorCode(response, dataObject) ?? "Unknown";
        const errorMetadata = {
            $metadata: metadata,
            $fault: response.statusCode <= 500 ? "client" : "server",
        };
        let namespace = this.options.defaultNamespace;
        if (errorName.includes("#")) {
            [namespace] = errorName.split("#");
        }
        const registry = this.compositeErrorRegistry;
        const nsRegistry = TypeRegistry.for(namespace);
        registry.copyFrom(nsRegistry);
        let errorSchema;
        try {
            errorSchema = registry.getSchema(errorName);
        }
        catch (ignored) {
            if (dataObject.Message) {
                dataObject.message = dataObject.Message;
            }
            const syntheticRegistry = TypeRegistry.for("smithy.ts.sdk.synthetic." + namespace);
            registry.copyFrom(syntheticRegistry);
            const baseExceptionSchema = registry.getBaseException();
            if (baseExceptionSchema) {
                const ErrorCtor = registry.getErrorCtor(baseExceptionSchema);
                throw Object.assign(new ErrorCtor({ name: errorName }), errorMetadata, dataObject);
            }
            throw Object.assign(new Error(errorName), errorMetadata, dataObject);
        }
        const ns = NormalizedSchema.of(errorSchema);
        const ErrorCtor = registry.getErrorCtor(errorSchema);
        const message = dataObject.message ?? dataObject.Message ?? "Unknown";
        const exception = new ErrorCtor({});
        const output = {};
        for (const [name, member] of ns.structIterator()) {
            output[name] = this.deserializer.readValue(member, dataObject[name]);
        }
        throw Object.assign(exception, errorMetadata, {
            $fault: ns.getMergedTraits().error,
            message,
        }, output);
    }
    getDefaultContentType() {
        return "application/cbor";
    }
}

exports.CborCodec = CborCodec;
exports.CborShapeDeserializer = CborShapeDeserializer;
exports.CborShapeSerializer = CborShapeSerializer;
exports.SmithyRpcV2CborProtocol = SmithyRpcV2CborProtocol;
exports.buildHttpRpcRequest = buildHttpRpcRequest;
exports.cbor = cbor;
exports.checkCborResponse = checkCborResponse;
exports.dateToTag = dateToTag;
exports.loadSmithyRpcV2CborErrorCode = loadSmithyRpcV2CborErrorCode;
exports.parseCborBody = parseCborBody;
exports.parseCborErrorBody = parseCborErrorBody;
exports.tag = tag;
exports.tagSymbol = tagSymbol;
