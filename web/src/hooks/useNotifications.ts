import { useState, useEffect, useRef, useCallback } from 'react';
import { createConsumer } from '@rails/actioncable';

export interface BookingNotification {
  type: 'booking.created' | 'booking.cancelled';
  booking: {
    id: number;
    confirmation_code: string;
    status: string;
    players_count: number;
    total_cents: number;
    customer_name: string;
    tee_time: string;
    date: string;
    course_name: string;
    cancellation_reason?: string;
  };
  timestamp: string;
}

const CABLE_URL = `ws://localhost:3003/cable`;

export function useNotifications() {
  const [notifications, setNotifications] = useState<BookingNotification[]>([]);
  const [connected, setConnected] = useState(false);
  const consumerRef = useRef<ReturnType<typeof createConsumer> | null>(null);
  const subscriptionRef = useRef<any>(null);

  const connect = useCallback(() => {
    const token = localStorage.getItem('token');
    if (!token) return;

    const consumer = createConsumer(`${CABLE_URL}?token=${token}`);
    consumerRef.current = consumer;

    subscriptionRef.current = consumer.subscriptions.create('NotificationsChannel', {
      connected() {
        setConnected(true);
      },
      disconnected() {
        setConnected(false);
      },
      received(data: BookingNotification) {
        setNotifications((prev) => [data, ...prev]);
      },
    });
  }, []);

  const disconnect = useCallback(() => {
    if (subscriptionRef.current) {
      subscriptionRef.current.unsubscribe();
      subscriptionRef.current = null;
    }
    if (consumerRef.current) {
      consumerRef.current.disconnect();
      consumerRef.current = null;
    }
    setConnected(false);
  }, []);

  const clearNotifications = useCallback(() => {
    setNotifications([]);
  }, []);

  useEffect(() => {
    connect();
    return () => disconnect();
  }, [connect, disconnect]);

  return { notifications, connected, clearNotifications };
}
