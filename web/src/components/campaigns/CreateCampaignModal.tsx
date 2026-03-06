import { useState, type FormEvent } from "react";
import { useMutation } from "@apollo/client";
import { CREATE_SMS_CAMPAIGN } from "../../graphql/mutations";
import { GET_SMS_CAMPAIGNS } from "../../graphql/queries";
import { Modal } from "../ui/Modal";
import { Button } from "../ui/Button";
import { Input } from "../ui/Input";

interface CreateCampaignModalProps {
  isOpen: boolean;
  onClose: () => void;
}

const RECIPIENT_FILTERS = [
  { value: "all", label: "All users with phone numbers" },
  { value: "members_only", label: "Active members only" },
  { value: "recent_bookers", label: "Recent bookers (last 30 days)" },
  { value: "inactive", label: "Inactive users (90+ days)" },
];

export function CreateCampaignModal({
  isOpen,
  onClose,
}: CreateCampaignModalProps) {
  const [name, setName] = useState("");
  const [messageBody, setMessageBody] = useState("");
  const [recipientFilter, setRecipientFilter] = useState("all");
  const [scheduleType, setScheduleType] = useState<"now" | "later">("now");
  const [scheduledAt, setScheduledAt] = useState("");

  const [createCampaign, { loading, error }] = useMutation(
    CREATE_SMS_CAMPAIGN,
    {
      refetchQueries: [{ query: GET_SMS_CAMPAIGNS }],
      onCompleted: (data) => {
        if (data.createSmsCampaign.errors.length === 0) {
          resetForm();
          onClose();
        }
      },
    }
  );

  const resetForm = () => {
    setName("");
    setMessageBody("");
    setRecipientFilter("all");
    setScheduleType("now");
    setScheduledAt("");
  };

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    createCampaign({
      variables: {
        name,
        messageBody,
        recipientFilter,
        scheduledAt:
          scheduleType === "later" && scheduledAt ? scheduledAt : null,
      },
    });
  };

  const charCount = messageBody.length;
  const segmentCount = Math.ceil(charCount / 160) || 1;

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Create SMS Campaign">
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label
            htmlFor="campaign-name"
            className="block text-sm font-medium text-rough-700"
          >
            Campaign Name
          </label>
          <Input
            id="campaign-name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Spring Weekend Special"
            required
          />
        </div>

        <div>
          <label
            htmlFor="message-body"
            className="block text-sm font-medium text-rough-700"
          >
            Message
          </label>
          <textarea
            id="message-body"
            value={messageBody}
            onChange={(e) => setMessageBody(e.target.value)}
            placeholder="Book your tee time this weekend! Use code SPRING20 for 20% off."
            rows={4}
            maxLength={1600}
            required
            className="mt-1 block w-full rounded-md border border-rough-300 px-3 py-2 text-sm shadow-sm focus:border-fairway-500 focus:outline-none focus:ring-1 focus:ring-fairway-500"
          />
          <div className="mt-1 flex justify-between text-xs text-rough-500">
            <span>
              {charCount}/1600 characters ({segmentCount}{" "}
              {segmentCount === 1 ? "segment" : "segments"})
            </span>
            {charCount > 160 && (
              <span className="text-amber-600">
                Multi-segment messages cost more
              </span>
            )}
          </div>
        </div>

        <div>
          <label
            htmlFor="recipient-filter"
            className="block text-sm font-medium text-rough-700"
          >
            Recipients
          </label>
          <select
            id="recipient-filter"
            value={recipientFilter}
            onChange={(e) => setRecipientFilter(e.target.value)}
            className="mt-1 block w-full rounded-md border border-rough-300 px-3 py-2 text-sm shadow-sm focus:border-fairway-500 focus:outline-none focus:ring-1 focus:ring-fairway-500"
          >
            {RECIPIENT_FILTERS.map((filter) => (
              <option key={filter.value} value={filter.value}>
                {filter.label}
              </option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-rough-700">
            When to send
          </label>
          <div className="mt-1 flex gap-4">
            <label className="flex items-center gap-2">
              <input
                type="radio"
                name="scheduleType"
                value="now"
                checked={scheduleType === "now"}
                onChange={() => setScheduleType("now")}
                className="text-fairway-600"
              />
              <span className="text-sm">Save as draft</span>
            </label>
            <label className="flex items-center gap-2">
              <input
                type="radio"
                name="scheduleType"
                value="later"
                checked={scheduleType === "later"}
                onChange={() => setScheduleType("later")}
                className="text-fairway-600"
              />
              <span className="text-sm">Schedule for later</span>
            </label>
          </div>
          {scheduleType === "later" && (
            <Input
              type="datetime-local"
              value={scheduledAt}
              onChange={(e) => setScheduledAt(e.target.value)}
              className="mt-2"
              required
            />
          )}
        </div>

        {error && (
          <p className="text-sm text-red-600">
            Error creating campaign: {error.message}
          </p>
        )}

        <div className="flex justify-end gap-3 pt-2">
          <Button variant="secondary" type="button" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" loading={loading} disabled={!name || !messageBody}>
            Create Campaign
          </Button>
        </div>
      </form>
    </Modal>
  );
}
