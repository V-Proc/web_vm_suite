import type { CSSProperties, ReactNode } from "react";
import styles from "./button.module.scss";

interface ButtonProps {
  children: ReactNode;
  onClick?: () => void;
  disabled?: boolean;
  loading?: boolean;
  style?: CSSProperties;
}

export const Button = ({ children, onClick, disabled, loading, style }: ButtonProps) => (
  <button
    type="button"
    className={styles["shared-button"]}
    onClick={onClick}
    disabled={disabled || loading}
    style={style}
  >
    {loading ? "..." : children}
  </button>
);
