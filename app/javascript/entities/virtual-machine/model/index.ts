import type { VmStatus } from "../../../shared";
import type { VirtualMachine } from "../../../shared";

export type { VmStatus, VirtualMachine };

export const VM_LABELS: Record<VmStatus, string> = {
  created: "Создана",
  running: "Работает",
  stopped: "Остановлена",
};

export const isRunning = (vm: VirtualMachine) => vm.status === "running";

export const canStart = (vm: VirtualMachine) =>
  vm.status === "created" || vm.status === "stopped";

export const canStop = (vm: VirtualMachine) => vm.status === "running";
