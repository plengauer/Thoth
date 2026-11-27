const opentelemetry_core = require('@opentelemetry/core');
const opentelemetry_propagator_b3 = require('@opentelemetry/propagator-b3');
const propagators = { tracecontext: () => new opentelemetry_core.W3CTraceContextPropagator(), b3: () => new opentelemetry_propagator_b3.B3Propagator(), baggage: () => new opentelemetry_core.W3CBaggagePropagator() };
const names = new Set((process.env.OTEL_PROPAGATORS || 'tracecontext,baggage').split(',').map(name => name.trim().toLowerCase()));
if (!names.has('tracecontext') && !names.has('b3') && [ ...names ].some(name => ![ '', 'none', 'baggage' ].includes(name))) names.add('tracecontext');

module.exports = new opentelemetry_core.CompositePropagator({ propagators: [ ...names ].filter(name => name in propagators).map(name => propagators[name]()) });
