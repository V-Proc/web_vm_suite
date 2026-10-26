import { useCallback, useState } from "react";
import { Button } from "../../../shared";
import type { VirtualMachine } from "../../../shared";
import { fetchConsoleInfo } from "../model";
import type { ConsoleInfo } from "../model";
import { ConsoleWindow } from "./console-window";
import styles from "./console-button.module.scss";

interface ConsoleButtonProps {
  vm: VirtualMachine;
}

export const ConsoleButton = ({ vm }: ConsoleButtonProps) => {
  const [info, setInfo] = useState<ConsoleInfo | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [pending, setPending] = useState(false);

  const open = useCallback(async () => {
    setPending(true);
    setError(null);
    try {
      setInfo(await fetchConsoleInfo(vm));
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setPending(false);
    }
  }, [vm]);

  const close = useCallback(() => setInfo(null), []);

  if (info) {
    return <ConsoleWindow info={info} onClose={close} />;
  }

  return (
    <span className={styles["console-button"]}>
      <Button onClick={() => void open()} loading={pending}>
        Консоль
      </Button>
      {error && <p className={styles["console-button__error"]}>{error}</p>}
    </span>
  );
};
