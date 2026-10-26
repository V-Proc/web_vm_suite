import type { HTMLAttributes } from "react";
import { StatusBadge } from "../../../../shared";
import type { VirtualMachine } from "../../model";
import { VM_LABELS } from "../../model";
import styles from "./vm-card.module.scss";

interface VmCardProps {
  vm: VirtualMachine;
  actions?: HTMLAttributes<HTMLDivElement>["children"];
}

export const VmCard = ({ vm, actions }: VmCardProps) => (
  <div className={styles["vm-card"]}>
    <div className={styles["vm-card__header"]}>
      <h3 className={styles["vm-card__title"]}>{vm.name}</h3>
      <StatusBadge status={vm.status} />
    </div>

    <dl className={styles["vm-card__specs"]}>
      <div className={styles["vm-card__spec"]}>
        <dt className={styles["vm-card__spec-name"]}>Владелец</dt>
        <dd className={styles["vm-card__spec-value"]}>{vm.owner.login}</dd>
      </div>
      <div className={styles["vm-card__spec"]}>
        <dt className={styles["vm-card__spec-name"]}>CPU</dt>
        <dd className={styles["vm-card__spec-value"]}>{vm.config.cpuCores}</dd>
      </div>
      <div className={styles["vm-card__spec"]}>
        <dt className={styles["vm-card__spec-name"]}>RAM</dt>
        <dd className={styles["vm-card__spec-value"]}>{vm.config.ramMb} МБ</dd>
      </div>
      <div className={styles["vm-card__spec"]}>
        <dt className={styles["vm-card__spec-name"]}>Disk</dt>
        <dd className={styles["vm-card__spec-value"]}>{vm.config.diskGb} ГБ</dd>
      </div>
      <div className={styles["vm-card__spec"]}>
        <dt className={styles["vm-card__spec-name"]}>UUID</dt>
        <dd className={styles["vm-card__spec-value"]}>{vm.uuid ?? "—"}</dd>
      </div>
    </dl>

    {actions && <div className={styles["vm-card__actions"]}>{actions}</div>}
  </div>
);
