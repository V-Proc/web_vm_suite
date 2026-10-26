import { useCallback, useEffect, useRef, useState } from "react";
import type RFB from "@novnc/novnc/core/rfb.js";
import styles from "./console-window.module.scss";
import type { ConsoleInfo } from "../model";

interface ConsoleWindowProps {
  info: ConsoleInfo;
  onClose: () => void;
}

export const ConsoleWindow = ({ info, onClose }: ConsoleWindowProps) => {
  const hostRef = useRef<HTMLDivElement>(null);
  const rfbRef = useRef<RFB | null>(null);
  const [connected, setConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    import("@novnc/novnc/core/rfb.js")
      .then(({ default: local_rfb }) => {
        if (cancelled || !hostRef.current) {
          return;
        }

        const rfb = new local_rfb(hostRef.current, info.wsUrl, {});
        rfbRef.current = rfb;
        rfb.scaleViewport = true;
        rfb.resizeSession = false;
        rfb.background = "#0f172a";

        rfb.addEventListener("connect", () => setConnected(true));
        rfb.addEventListener("disconnect", () => setConnected(false));
      })
      .catch((e: unknown) => setError((e as Error).message));

    return () => {
      cancelled = true;
      rfbRef.current?.disconnect();
      rfbRef.current = null;
    };
  }, [info.wsUrl]);

  const sendCtrlAltDel = useCallback(() => {
    rfbRef.current?.sendCtrlAltDel();
  }, []);

  return (
    <div className={styles["console-window"]}>
      <header className={styles["console-window__header"]}>
        <span className={styles["console-window__title"]}>Консоль: {info.vmName}</span>
        <span className={styles["console-window__status"]}>
          {connected ? "подключено" : "не подключено"}
        </span>
        <span
          className={styles["console-window__toolbar"]}
        >
          <button
            type="button"
            className={styles["console-window__tool"]}
            onClick={sendCtrlAltDel}
          >
            Ctrl+Alt+Del
          </button>
          <button
            type="button"
            className={styles["console-window__tool"]}
            onClick={onClose}
          >
            Закрыть
          </button>
        </span>
      </header>

      <div ref={hostRef} className={styles["console-window__screen"]} />
      {error && <p className={styles["console-window__error"]}>{error}</p>}
    </div>
  );
};
