import type { VirtualMachineConfig } from "../../../shared";
import { VmConfigCard } from "../../../entities/virtual-machine-config";
import styles from "./vm-config-list.module.scss";

interface VmConfigListProps {
  configs: VirtualMachineConfig[];
}

export const VmConfigList = ({ configs }: VmConfigListProps) => (
  <div className={styles["vm-config-list"]}>
    {configs.map((c) => (
      <VmConfigCard key={c.id} config={c} />
    ))}
  </div>
);
