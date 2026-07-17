'use strict'

// The export-collection logic (resolving star re-exports, reading source,
// parsing exports) is identical whether `import-in-the-middle` runs as an
// off-thread loader (`module.register`, asynchronous `nextResolve`/`nextLoad`)
// or as an in-thread synchronous loader (`module.registerHooks`). To keep a
// single implementation of that logic — instead of two copies that drift — it
// is written as "sans-io" generators that `yield` the I/O they need and let a
// driver fulfil it. The async driver awaits; the sync driver calls straight
// through. Everything between the yields is shared.

// Operation kinds a loader generator may yield. Each is `[KIND, ...args]`.
export const LOAD = 0 // [LOAD, url, context]      -> resolves to { source, format }
export const RESOLVE = 1 // [RESOLVE, specifier, context] -> resolves to { url, format }

function runOp (op, io) {
  if (op[0] === RESOLVE) {
    return io.resolve(op[1], op[2])
  }
  return io.load(op[1], op[2])
}

/**
 * Drives a loader generator to completion, fulfilling each yielded I/O
 * operation synchronously. Used with `module.registerHooks`, whose
 * `nextResolve`/`nextLoad` return their result directly.
 *
 * Errors from I/O are thrown back into the generator (via `gen.throw`) so its
 * `try`/`finally` blocks run exactly as they would for an `await` rejection.
 *
 * @template T
 * @param {Generator<Array, T>} gen
 * @param {{ load: Function, resolve?: Function }} io
 * @returns {T}
 */
export function driveSync (gen, io) {
  let next = gen.next()
  while (next.done === false) {
    let result
    let error
    let threw = false
    try {
      result = runOp(next.value, io)
    } catch (err) {
      threw = true
      error = err
    }
    next = threw ? gen.throw(error) : gen.next(result)
  }
  return next.value
}

/**
 * Drives a loader generator to completion, awaiting each yielded I/O
 * operation. Used with the off-thread `module.register` loader, whose
 * `nextResolve`/`nextLoad` are asynchronous.
 *
 * @template T
 * @param {Generator<Array, T>} gen
 * @param {{ load: Function, resolve?: Function }} io
 * @returns {Promise<T>}
 */
export async function driveAsync (gen, io) {
  let next = gen.next()
  while (next.done === false) {
    let result
    let error
    let threw = false
    try {
      result = await runOp(next.value, io)
    } catch (err) {
      threw = true
      error = err
    }
    next = threw ? gen.throw(error) : gen.next(result)
  }
  return next.value
}
