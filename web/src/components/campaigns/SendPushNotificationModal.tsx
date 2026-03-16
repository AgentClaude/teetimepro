import { useState, type FormEvent } from "react";
import { gql, useMutation, useQuery } from "@apollo/client";
import { Modal } from "../ui/Modal";
import { Button } from "../ui/Button";
import { Input } from "../ui/Input";

const SEND_PROMOTIONAL_PUSH = gql`
  mutation SendPromotionalPush(
    $title: String!
    $body: String!
    $segmentId: ID
  ) {
    sendPromotionalPush(title: $title, body: $body, segmentId: $segmentId) {
      sent
      failed
      errors
    }
  }
`;

const GET_SEGMENTS = gql`
  query GetGolferSegments {
    golferSegments {
      id
      name
      memberCount
    }
  }
`;

interface SendPushNotificationModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function SendPushNotificationModal({
  isOpen,
  onClose,
}: SendPushNotificationModalProps) {
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [segmentId, setSegmentId] = useState<string>("");
  const [result, setResult] = useState<{
    sent: number;
    failed: number;
  } | null>(null);

  const { data: segmentsData } = useQuery(GET_SEGMENTS);
  const [sendPush, { loading, error }] = useMutation(SEND_PROMOTIONAL_PUSH);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();

    const { data } = await sendPush({
      variables: {
        title,
        body,
        segmentId: segmentId || undefined,
      },
    });

    if (data?.sendPromotionalPush?.errors?.length === 0) {
      setResult({
        sent: data.sendPromotionalPush.sent,
        failed: data.sendPromotionalPush.failed ?? 0,
      });
    }
  };

  const handleClose = () => {
    setTitle("");
    setBody("");
    setSegmentId("");
    setResult(null);
    onClose();
  };

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Send Push Notification">
      {result ? (
        <div className="space-y-4">
          <div className="rounded-lg bg-green-50 p-4 text-green-800">
            <p className="font-medium">
              Push notification sent to {result.sent} device
              {result.sent !== 1 ? "s" : ""}
            </p>
            {result.failed > 0 && (
              <p className="mt-1 text-sm text-yellow-700">
                {result.failed} delivery failure{result.failed !== 1 ? "s" : ""}
              </p>
            )}
          </div>
          <Button onClick={handleClose} variant="secondary" className="w-full">
            Done
          </Button>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label
              htmlFor="push-title"
              className="block text-sm font-medium text-gray-700"
            >
              Title
            </label>
            <Input
              id="push-title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="e.g., Weekend Special ⛳"
              required
              maxLength={50}
            />
          </div>

          <div>
            <label
              htmlFor="push-body"
              className="block text-sm font-medium text-gray-700"
            >
              Message
            </label>
            <textarea
              id="push-body"
              value={body}
              onChange={(e) => setBody(e.target.value)}
              placeholder="e.g., 20% off all tee times this Saturday!"
              required
              maxLength={178}
              rows={3}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500 sm:text-sm"
            />
            <p className="mt-1 text-xs text-gray-500">
              {body.length}/178 characters
            </p>
          </div>

          <div>
            <label
              htmlFor="push-segment"
              className="block text-sm font-medium text-gray-700"
            >
              Target Audience
            </label>
            <select
              id="push-segment"
              value={segmentId}
              onChange={(e) => setSegmentId(e.target.value)}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500 sm:text-sm"
            >
              <option value="">All registered devices</option>
              {segmentsData?.golferSegments?.map(
                (segment: { id: string; name: string; memberCount: number }) => (
                  <option key={segment.id} value={segment.id}>
                    {segment.name} ({segment.memberCount} members)
                  </option>
                )
              )}
            </select>
          </div>

          {error && (
            <div className="rounded-md bg-red-50 p-3 text-sm text-red-700">
              {error.message}
            </div>
          )}

          <div className="flex gap-3">
            <Button
              type="button"
              variant="secondary"
              onClick={handleClose}
              className="flex-1"
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={loading || !title || !body}
              className="flex-1"
            >
              {loading ? "Sending..." : "Send Push"}
            </Button>
          </div>
        </form>
      )}
    </Modal>
  );
}
