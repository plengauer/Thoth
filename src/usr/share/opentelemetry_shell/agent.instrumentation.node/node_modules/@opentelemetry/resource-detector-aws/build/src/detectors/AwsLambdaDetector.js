"use strict";
/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.awsLambdaDetector = exports.AwsLambdaDetector = void 0;
const semconv_1 = require("../semconv");
/**
 * The AwsLambdaDetector can be used to detect if a process is running in AWS Lambda
 * and return a {@link Resource} populated with data about the environment.
 * Returns an empty Resource if detection fails.
 */
class AwsLambdaDetector {
    detect() {
        // Check if running inside AWS Lambda environment
        const executionEnv = process.env.AWS_EXECUTION_ENV;
        if (!executionEnv?.startsWith('AWS_Lambda_')) {
            return {};
        }
        // These environment variables are guaranteed to be present in Lambda environment
        // https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html#configuration-envvars-runtime
        const region = process.env.AWS_REGION;
        const functionName = process.env.AWS_LAMBDA_FUNCTION_NAME;
        const functionVersion = process.env.AWS_LAMBDA_FUNCTION_VERSION;
        const memorySize = process.env.AWS_LAMBDA_FUNCTION_MEMORY_SIZE;
        // These environment variables are not available in Lambda SnapStart functions
        const logGroupName = process.env.AWS_LAMBDA_LOG_GROUP_NAME;
        const logStreamName = process.env.AWS_LAMBDA_LOG_STREAM_NAME;
        const attributes = {
            [semconv_1.ATTR_CLOUD_PROVIDER]: semconv_1.CLOUD_PROVIDER_VALUE_AWS,
            [semconv_1.ATTR_CLOUD_PLATFORM]: semconv_1.CLOUD_PLATFORM_VALUE_AWS_LAMBDA,
            [semconv_1.ATTR_CLOUD_REGION]: region,
            [semconv_1.ATTR_FAAS_NAME]: functionName,
            [semconv_1.ATTR_FAAS_VERSION]: functionVersion,
            [semconv_1.ATTR_FAAS_MAX_MEMORY]: parseInt(memorySize) * 1024 * 1024,
        };
        if (logGroupName) {
            attributes[semconv_1.ATTR_AWS_LOG_GROUP_NAMES] = [logGroupName];
        }
        if (logStreamName) {
            attributes[semconv_1.ATTR_FAAS_INSTANCE] = logStreamName;
        }
        return { attributes };
    }
}
exports.AwsLambdaDetector = AwsLambdaDetector;
exports.awsLambdaDetector = new AwsLambdaDetector();
//# sourceMappingURL=AwsLambdaDetector.js.map