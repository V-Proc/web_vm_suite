export interface Workgroup {
  id: number;
  name: string;
}

export interface User {
  id: number;
  login: string;
  role: "admin" | "member";
  workgroupId: number;
}

export interface VirtualMachineConfig {
  id: number;
  name: string;
  cpuCores: number;
  ramMb: number;
  diskGb: number;
}

export type VmStatus = "created" | "running" | "stopped";

export interface VirtualMachine {
  id: number;
  name: string;
  uuid: string | null;
  status: VmStatus;
  owner: { id: number; login: string };
  workgroup: { id: number; name: string };
  config: VirtualMachineConfig;
  createdAt: string;
  updatedAt: string;
}
