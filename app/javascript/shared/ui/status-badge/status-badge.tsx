import styles from "./status-badge.module.scss";
import type { VmStatus } from "../../api";

export const StatusBadge = ({ status }: { status: VmStatus }) => (
  <span className={`${styles["status-badge"]} ${styles[`status-badge--${status}`]}`}>
    {status}
  </span>
);
