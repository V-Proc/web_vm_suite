import { api } from "../../../shared";
import type { VirtualMachine } from "../../../shared";
import { Button } from "../../../shared";

interface DeleteVmButtonProps {
  vm: VirtualMachine;
  onDelete?: (vm: VirtualMachine) => void;
}

export const DeleteVmButton = ({ vm, onDelete }: DeleteVmButtonProps) => {
  const remove = async () => {
    await api(`/virtual_machines/${vm.id}`, { method: "DELETE" });
    onDelete?.(vm);
  };

  return (
    <Button onClick={remove}>
      Удалить
    </Button>
  );
};
