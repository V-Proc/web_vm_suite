import { api } from "../../../shared";
import type { VirtualMachine } from "../../../shared";

export interface ConsoleInfo {
  vmId: number;
  vmName: string;
  wsUrl: string;
  kind: "vnc" | "spice";
}

export const fetchConsoleInfo = (vm: VirtualMachine): Promise<ConsoleInfo> =>
  api<Raw>(`/virtual_machines/${vm.id}/console`).then((raw): ConsoleInfo => ({
    vmId: raw.vm_id,
    vmName: raw.vm_name,
    wsUrl: raw.ws_url,
    kind: raw.kind === "spice" ? "spice" : "vnc",
  }));

interface Raw {
  vm_id: number;
  vm_name: string;
  ws_url: string;
  kind: string;
}
