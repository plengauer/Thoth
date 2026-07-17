import type { CpuUsageData, MemoryData, ProcessCpuUsageData } from '../types';
/**
 * For each CPU returned by `os.cpus()` it returns
 * - the CPU times in each state (user, sys, ...) in seconds
 * - the % of time the CPU was in each state since last measurement
 */
export declare function getCpuUsageData(): CpuUsageData[];
/**
 * Gets the process CPU usage and returns
 * - the time spent in `user` state
 * - the time spent in `system` state
 * - the % of time in `user` state since last measurement
 * - the % of time in `system` state since last measurement
 */
export declare function getProcessCpuUsageData(): ProcessCpuUsageData;
/**
 * Returns memory data as absolute values
 */
export declare function getMemoryData(): MemoryData;
/**
 * Returns process memory RSS
 * The Resident Set Size, is the amount of space occupied in the main memory device (that is a subset of the total allocated memory) for the process,
 * including all C++ and JavaScript objects and code.
 */
export declare function getProcessMemoryData(): number;
//# sourceMappingURL=common.d.ts.map