#!/bin/false
# shellcheck shell=bash

# Go executables cannot be reliably identified for deep injection.
# Go applications with OpenTelemetry already embedded can still continue the
# trace by reading TRACEPARENT from their environment.
