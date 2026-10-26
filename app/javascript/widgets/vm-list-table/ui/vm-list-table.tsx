import type { VirtualMachine } from "../../../shared";
import { VmCard } from "../../../entities/virtual-machine";
import { canStart, canStop } from "../../../entities/virtual-machine";
import { StartVmButton } from "../../../features/start-vm";
import { StopVmButton } from "../../../features/stop-vm";
import { DeleteVmButton } from "../../../features/delete-vm";
import styles from "./vm-list-table.module.scss";

interface VmListTableProps {
  vms: VirtualMachine[];
  onChanged?: (vm: VirtualMachine) => void;
}

export const VmListTable = ({ vms, onChanged }: VmListTableProps) => {
  if (vms.length === 0) {
    return <p className={styles["vm-list-table__empty"]}>Список машин пуст</p>;
  }

  return (
    <div className={styles["vm-list-table"]}>
      {vms.map((vm) => (
        <VmCard
          key={vm.id}
          vm={vm}
          actions={
            <>
              {canStart(vm) && <StartVmButton vm={vm} onStart={onChanged} />}
              {canStop(vm) && <StopVmButton vm={vm} onStop={onChanged} />}
              <DeleteVmButton vm={vm} onDelete={onChanged} />
            </>
          }
        />
      ))}
    </div>
  );
};

