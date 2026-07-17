"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.SYNC_FUNCTIONS = exports.CALLBACK_FUNCTIONS = exports.PROMISE_FUNCTIONS = void 0;
exports.PROMISE_FUNCTIONS = [
    'access',
    'appendFile',
    'chmod',
    'chown',
    'copyFile',
    'cp',
    'lchown',
    'link',
    'lstat',
    'lutimes',
    'mkdir',
    'mkdtemp',
    'open',
    'opendir',
    'readdir',
    'readFile',
    'readlink',
    'realpath',
    'rename',
    'rm',
    'rmdir',
    'stat',
    'symlink',
    'truncate',
    'unlink',
    'utimes',
    'writeFile',
    // 'lchmod', // only implemented on macOS
];
exports.CALLBACK_FUNCTIONS = [
    'access',
    'appendFile',
    'chmod',
    'chown',
    'copyFile',
    'cp',
    'exists',
    'lchown',
    'link',
    'lstat',
    'lutimes',
    'mkdir',
    'mkdtemp',
    'open',
    'opendir',
    'readdir',
    'readFile',
    'readlink',
    'realpath',
    'realpath.native',
    'rename',
    'rm',
    'rmdir',
    'stat',
    'symlink',
    'truncate',
    'unlink',
    'utimes',
    'writeFile',
    // 'close', // functions on file descriptor
    // 'fchmod', // functions on file descriptor
    // 'fchown', // functions on file descriptor
    // 'fdatasync', // functions on file descriptor
    // 'fstat', // functions on file descriptor
    // 'fsync', // functions on file descriptor
    // 'ftruncate', // functions on file descriptor
    // 'futimes', // functions on file descriptor
    // 'lchmod', // only implemented on macOS
    // 'read', // functions on file descriptor
    // 'readv', // functions on file descriptor
    // 'write', // functions on file descriptor
    // 'writev', // functions on file descriptor
];
exports.SYNC_FUNCTIONS = [
    'accessSync',
    'appendFileSync',
    'chmodSync',
    'chownSync',
    'copyFileSync',
    'cpSync',
    'existsSync',
    'lchownSync',
    'linkSync',
    'lstatSync',
    'lutimesSync',
    'mkdirSync',
    'mkdtempSync',
    'opendirSync',
    'openSync',
    'readdirSync',
    'readFileSync',
    'readlinkSync',
    'realpathSync',
    'realpathSync.native',
    'renameSync',
    'rmdirSync',
    'rmSync',
    'statSync',
    'symlinkSync',
    'truncateSync',
    'unlinkSync',
    'utimesSync',
    'writeFileSync',
    // 'closeSync', // functions on file descriptor
    // 'fchmodSync', // functions on file descriptor
    // 'fchownSync', // functions on file descriptor
    // 'fdatasyncSync', // functions on file descriptor
    // 'fstatSync', // functions on file descriptor
    // 'fsyncSync', // functions on file descriptor
    // 'ftruncateSync', // functions on file descriptor
    // 'futimesSync', // functions on file descriptor
    // 'lchmodSync', // only implemented on macOS
    // 'readSync', // functions on file descriptor
    // 'readvSync', // functions on file descriptor
    // 'writeSync', // functions on file descriptor
    // 'writevSync', // functions on file descriptor
];
//# sourceMappingURL=constants.js.map