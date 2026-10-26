import styles from "./vm-config-card.module.scss";
import type { VirtualMachineConfig } from "../../model";
import { formatConfig } from "../../model";

export const VmConfigCard = ({ config }: { config: VirtualMachineConfig }) => (
  <div className={styles["vm-config-card"]}>
    <span className={styles["vm-config-card__name"]}>{config.name}</span>
    <span className={styles["vm-config-card__resources"]}>{formatConfig(config)}</span>
  </div>
);
