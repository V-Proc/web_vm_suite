declare module "@novnc/novnc/core/rfb.js" {
  export default class RFB extends EventTarget {
    constructor(target: HTMLElement, urlOrChannel: string | WebSocket, options?: Record<string, unknown>);
       scaleViewport: boolean;    resizeSession: boolean;
    background: string;
    disconnect(): void;
    sendCtrlAltDel(): void;
    sendKey(keysym: string, down?: boolean): void;
    sendCredentials(creds: { username: string; password: string }): void;
  }
}
