import { loadConfig } from "@smithy/core/config";
import { getEndpointUrlConfig } from "./getEndpointUrlConfig";
export const getEndpointFromConfig = async (serviceId) => loadConfig(getEndpointUrlConfig(serviceId ?? ""))();
