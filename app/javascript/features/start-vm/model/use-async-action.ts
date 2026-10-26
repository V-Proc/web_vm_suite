import { useCallback, useState } from "react";

export const useAsyncAction = <T,>() => {
  const [pending, setPending] = useState(false);

  const execute = useCallback(async (fn: () => Promise<T>, onDone?: (v: T) => void) => {
    setPending(true);
    try {
      const result = await fn();
      onDone?.(result);
      return result;
    } finally {
      setPending(false);
    }
  }, []);

  return { execute, pending };
};
