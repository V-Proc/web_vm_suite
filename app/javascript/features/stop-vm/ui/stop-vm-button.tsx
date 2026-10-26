import { api } from "../../../shared";
import type { VirtualMachine } from "../../../shared";
import { useAsyncAction } from "../model/use-async-action";
import { Button } from "../../../shared";

interface StopVmButtonProps {
  vm: VirtualMachine;
  onStop?: (vm: VirtualMachine) => void;
}

export const StopVmButton = ({ vm, onStop }: StopVmButtonProps) => {
  const { execute, pending } = useAsyncAction<VirtualMachine>();

  const stop = () =>
    execute(
      () => api(`/virtual_machines/${vm.id}/stop`, { method: "POST" }),
      onStop,
    );

  return (
    <Button onClick={stop} loading={pending}>
      Остановить
    </Button>
  );
};
