import { api } from "../../../shared";
import type { VirtualMachine } from "../../../shared";
import { useAsyncAction } from "../model/use-async-action";
import { Button } from "../../../shared";

interface StartVmButtonProps {
  vm: VirtualMachine;
  onStart?: (vm: VirtualMachine) => void;
}

export const StartVmButton = ({ vm, onStart }: StartVmButtonProps) => {
  const { execute, pending } = useAsyncAction<VirtualMachine>();

  const start = () =>
    execute(
      () => api(`/virtual_machines/${vm.id}/start`, { method: "POST" }),
      onStart,
    );

  return (
    <Button onClick={start} loading={pending}>
      Запустить
    </Button>
  );
};
