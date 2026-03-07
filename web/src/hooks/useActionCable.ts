import { useEffect, useRef, useCallback, useState } from "react";
import { createConsumer, Consumer, Subscription } from "@rails/actioncable";

const CABLE_URL =
  import.meta.env.VITE_CABLE_URL || "ws://localhost:3000/cable";

let sharedConsumer: Consumer | null = null;

function getConsumer(): Consumer {
  if (!sharedConsumer) {
    const token = localStorage.getItem("auth_token");
    const url = token ? `${CABLE_URL}?token=${token}` : CABLE_URL;
    sharedConsumer = createConsumer(url);
  }
  return sharedConsumer;
}

export function resetConsumer(): void {
  if (sharedConsumer) {
    sharedConsumer.disconnect();
    sharedConsumer = null;
  }
}

interface UseChannelOptions<T> {
  channel: string;
  params?: Record<string, string | number>;
  onReceived: (data: T) => void;
  onConnected?: () => void;
  onDisconnected?: () => void;
}

export function useChannel<T>({
  channel,
  params = {},
  onReceived,
  onConnected,
  onDisconnected,
}: UseChannelOptions<T>): {
  connected: boolean;
  send: (action: string, data?: Record<string, unknown>) => void;
} {
  const [connected, setConnected] = useState(false);
  const subscriptionRef = useRef<Subscription | null>(null);
  const callbacksRef = useRef({ onReceived, onConnected, onDisconnected });

  callbacksRef.current = { onReceived, onConnected, onDisconnected };

  const paramsKey = JSON.stringify(params);

  useEffect(() => {
    const consumer = getConsumer();
    const parsedParams = JSON.parse(paramsKey) as Record<string, string | number>;

    const subscription = consumer.subscriptions.create(
      { channel, ...parsedParams },
      {
        connected() {
          setConnected(true);
          callbacksRef.current.onConnected?.();
        },
        disconnected() {
          setConnected(false);
          callbacksRef.current.onDisconnected?.();
        },
        received(data: T) {
          callbacksRef.current.onReceived(data);
        },
      }
    );

    subscriptionRef.current = subscription;

    return () => {
      subscription.unsubscribe();
      subscriptionRef.current = null;
      setConnected(false);
    };
  }, [channel, paramsKey]);

  const send = useCallback(
    (action: string, data?: Record<string, unknown>) => {
      subscriptionRef.current?.perform(action, data);
    },
    []
  );

  return { connected, send };
}
