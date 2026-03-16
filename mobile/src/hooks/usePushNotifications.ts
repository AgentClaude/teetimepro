import { useEffect, useRef, useState } from "react";
import { gql, useMutation } from "@apollo/client";
import {
  configureNotifications,
  registerForPushNotifications,
  getDevicePlatform,
  addNotificationReceivedListener,
  addNotificationResponseListener,
} from "../services/notifications";
import type { Notification, NotificationResponse } from "expo-notifications";

const REGISTER_DEVICE_TOKEN = gql`
  mutation RegisterDeviceToken(
    $token: String!
    $platform: String!
    $deviceId: String
  ) {
    registerDeviceToken(
      token: $token
      platform: $platform
      deviceId: $deviceId
    ) {
      deviceToken {
        id
        platform
        active
      }
      errors
    }
  }
`;

interface UsePushNotificationsOptions {
  /** Called when a notification is received while app is in foreground */
  onNotificationReceived?: (notification: Notification) => void;
  /** Called when user taps a notification */
  onNotificationResponse?: (response: NotificationResponse) => void;
}

interface UsePushNotificationsResult {
  expoPushToken: string | null;
  isRegistered: boolean;
  error: string | null;
}

export function usePushNotifications(
  options: UsePushNotificationsOptions = {}
): UsePushNotificationsResult {
  const [expoPushToken, setExpoPushToken] = useState<string | null>(null);
  const [isRegistered, setIsRegistered] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const notificationListener = useRef<ReturnType<
    typeof addNotificationReceivedListener
  > | null>(null);
  const responseListener = useRef<ReturnType<
    typeof addNotificationResponseListener
  > | null>(null);

  const [registerToken] = useMutation(REGISTER_DEVICE_TOKEN);

  useEffect(() => {
    configureNotifications();

    registerForPushNotifications()
      .then(async (token) => {
        if (!token) {
          setError("Could not get push token");
          return;
        }

        setExpoPushToken(token);

        try {
          const { data } = await registerToken({
            variables: {
              token,
              platform: getDevicePlatform(),
            },
          });

          if (data?.registerDeviceToken?.errors?.length > 0) {
            setError(data.registerDeviceToken.errors.join(", "));
          } else {
            setIsRegistered(true);
          }
        } catch (err) {
          setError(
            err instanceof Error ? err.message : "Failed to register token"
          );
        }
      })
      .catch((err) => {
        setError(
          err instanceof Error ? err.message : "Push notification setup failed"
        );
      });

    // Set up notification listeners
    notificationListener.current = addNotificationReceivedListener(
      (notification) => {
        options.onNotificationReceived?.(notification);
      }
    );

    responseListener.current = addNotificationResponseListener((response) => {
      options.onNotificationResponse?.(response);
    });

    return () => {
      notificationListener.current?.remove();
      responseListener.current?.remove();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return { expoPushToken, isRegistered, error };
}
