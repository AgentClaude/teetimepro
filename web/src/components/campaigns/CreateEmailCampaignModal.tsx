import { useState, type FormEvent } from "react";
import { useMutation } from "@apollo/client";
import { CREATE_EMAIL_CAMPAIGN } from "../../graphql/mutations";
import { GET_EMAIL_CAMPAIGNS } from "../../graphql/queries";
import { Modal } from "../ui/Modal";
import { Button } from "../ui/Button";
import { Input } from "../ui/Input";

interface CreateEmailCampaignModalProps {
  isOpen: boolean;
  onClose: () => void;
}

const RECIPIENT_FILTERS = [
  { value: "lapsed", label: "Lapsed golfers (no recent bookings)" },
  { value: "members_only", label: "Active members only" },
  { value: "inactive", label: "Inactive users (90+ days)" },
  { value: "all", label: "All users with emails" },
];

export function CreateEmailCampaignModal({
  isOpen,
  onClose,
}: CreateEmailCampaignModalProps) {
  const [name, setName] = useState("");
  const [subject, setSubject] = useState("");
  const [bodyHtml, setBodyHtml] = useState("");
  const [recipientFilter, setRecipientFilter] = useState("lapsed");
  const [lapsedDays, setLapsedDays] = useState(30);
  const [isAutomated, setIsAutomated] = useState(false);
  const [recurrenceIntervalDays, setRecurrenceIntervalDays] = useState(30);
  const [scheduleType, setScheduleType] = useState<"now" | "later">("now");
  const [scheduledAt, setScheduledAt] = useState("");

  const [createCampaign, { loading, error }] = useMutation(
    CREATE_EMAIL_CAMPAIGN,
    {
      refetchQueries: [{ query: GET_EMAIL_CAMPAIGNS }],
      onCompleted: (data) => {
        if (data.createEmailCampaign.errors.length === 0) {
          resetForm();
          onClose();
        }
      },
    }
  );

  const resetForm = () => {
    setName("");
    setSubject("");
    setBodyHtml("");
    setRecipientFilter("lapsed");
    setLapsedDays(30);
    setIsAutomated(false);
    setRecurrenceIntervalDays(30);
    setScheduleType("now");
    setScheduledAt("");
  };

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    createCampaign({
      variables: {
        name,
        subject,
        bodyHtml,
        recipientFilter,
        lapsedDays: recipientFilter === "lapsed" ? lapsedDays : null,
        isAutomated,
        recurrenceIntervalDays: isAutomated ? recurrenceIntervalDays : null,
        scheduledAt:
          scheduleType === "later" && scheduledAt ? scheduledAt : null,
      },
    });
  };

  const getDefaultEmailTemplate = () => {
    return `<p>Hi {{first_name}},</p>

<p>We've missed seeing you on the course at {{golf_course}}! It's been a while since your last round, and we wanted to reach out with a special invitation to get back on the greens.</p>

<p><strong>Limited Time Offer:</strong></p>
<ul>
  <li>20% off your next tee time</li>
  <li>Complimentary cart rental</li>
  <li>Valid for the next 30 days</li>
</ul>

<p>Our course is in pristine condition and we'd love to welcome you back. Whether you're looking for an early morning round or prefer twilight golf, we have tee times available to fit your schedule.</p>

<p>Ready to tee it up? <a href="{{booking_url}}">Book your comeback round today!</a></p>

<p>We look forward to seeing you soon.</p>

<p>Best regards,<br>
The {{golf_course}} Team</p>`;
  };

  const useDefaultTemplate = () => {
    setBodyHtml(getDefaultEmailTemplate());
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Create Email Campaign">
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
            placeholder="Spring Re-engagement Campaign"
            required
          />
        </div>

        <div>
          <label
            htmlFor="email-subject"
            className="block text-sm font-medium text-rough-700"
          >
            Subject Line
          </label>
          <Input
            id="email-subject"
            value={subject}
            onChange={(e) => setSubject(e.target.value)}
            placeholder="We miss you on the course, {{first_name}}!"
            required
          />
          <p className="mt-1 text-xs text-rough-500">
            Use {{first_name}}, {{name}}, or {{golf_course}} for personalization
          </p>
        </div>

        <div>
          <div className="flex items-center justify-between">
            <label
              htmlFor="email-body"
              className="block text-sm font-medium text-rough-700"
            >
              Email Content (HTML)
            </label>
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={useDefaultTemplate}
            >
              Use Template
            </Button>
          </div>
          <textarea
            id="email-body"
            value={bodyHtml}
            onChange={(e) => setBodyHtml(e.target.value)}
            placeholder="Enter your email content here..."
            rows={8}
            required
            className="mt-1 block w-full rounded-md border border-rough-300 px-3 py-2 text-sm shadow-sm focus:border-fairway-500 focus:outline-none focus:ring-1 focus:ring-fairway-500"
          />
          <p className="mt-1 text-xs text-rough-500">
            HTML formatting supported. Use {{first_name}}, {{name}}, {{golf_course}} for personalization
          </p>
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

        {recipientFilter === "lapsed" && (
          <div>
            <label
              htmlFor="lapsed-days"
              className="block text-sm font-medium text-rough-700"
            >
              Lapsed Days
            </label>
            <Input
              id="lapsed-days"
              type="number"
              value={lapsedDays}
              onChange={(e) => setLapsedDays(Number(e.target.value))}
              min={1}
              max={365}
              required
            />
            <p className="mt-1 text-xs text-rough-500">
              Target golfers who haven't booked in this many days
            </p>
          </div>
        )}

        <div>
          <label className="flex items-center gap-2">
            <input
              type="checkbox"
              checked={isAutomated}
              onChange={(e) => setIsAutomated(e.target.checked)}
              className="rounded border-rough-300 text-fairway-600 focus:ring-fairway-500"
            />
            <span className="text-sm font-medium text-rough-700">
              Automated recurring campaign
            </span>
          </label>
        </div>

        {isAutomated && (
          <div>
            <label
              htmlFor="recurrence-days"
              className="block text-sm font-medium text-rough-700"
            >
              Recurrence Interval (days)
            </label>
            <Input
              id="recurrence-days"
              type="number"
              value={recurrenceIntervalDays}
              onChange={(e) => setRecurrenceIntervalDays(Number(e.target.value))}
              min={1}
              max={365}
              required
            />
            <p className="mt-1 text-xs text-rough-500">
              How often to automatically send this campaign
            </p>
          </div>
        )}

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
              <span className="text-sm">Send immediately</span>
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
        </div>

        {scheduleType === "later" && (
          <div>
            <label
              htmlFor="scheduled-at"
              className="block text-sm font-medium text-rough-700"
            >
              Send Date & Time
            </label>
            <input
              id="scheduled-at"
              type="datetime-local"
              value={scheduledAt}
              onChange={(e) => setScheduledAt(e.target.value)}
              required
              className="mt-1 block w-full rounded-md border border-rough-300 px-3 py-2 text-sm shadow-sm focus:border-fairway-500 focus:outline-none focus:ring-1 focus:ring-fairway-500"
            />
          </div>
        )}

        {error && (
          <div className="rounded-md bg-red-50 p-3">
            <p className="text-sm text-red-800">
              {error.graphQLErrors?.[0]?.message ||
                error.message ||
                "Failed to create campaign"}
            </p>
          </div>
        )}

        <div className="flex justify-end gap-3 pt-4">
          <Button type="button" variant="ghost" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" loading={loading}>
            {scheduleType === "now" 
              ? (isAutomated ? "Create & Schedule" : "Create & Send")
              : "Create Campaign"}
          </Button>
        </div>
      </form>
    </Modal>
  );
}