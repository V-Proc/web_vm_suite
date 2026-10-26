import type { VirtualMachineConfig } from "../../../shared";
import type { Workgroup } from "../../../shared";

export type { VirtualMachineConfig, Workgroup };

export const formatConfig = (c: VirtualMachineConfig) =>
  `${c.cpuCores} vCPU / ${c.ramMb} МБ RAM / ${c.diskGb} ГБ`;
