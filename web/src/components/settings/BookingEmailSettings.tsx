import { useState } from "react";
import { useQuery, useMutation } from "@apollo/client";
import { Card } from "../ui/Card";
import { Button } from "../ui/Button";
import { EmailTemplatePreview } from "../campaigns/EmailTemplatePreview";
import {
  GET_BOOKING_EMAIL_TEMPLATES,
  GET_EMAIL_PROVIDERS,
} from "../../graphql/queries";
import {
  SEED_BOOKING_TEMPLATES,
  UPDATE_EMAIL_TEMPLATE,
} from "../../graphql/mutations";
import { EmailTemplate } from "../../types/emailProvider";

interface BookingEmailSettingsProps {
  onEditTemplate?: (template: EmailTemplate) => void;
}

export function BookingEmailSettings({
  onEditTemplate,
}: BookingEmailSettingsProps) {
  const [previewTemplate, setPreviewTemplate] = useState<EmailTemplate | null>(
    null
  );

  const { data, loading, refetch } = useQuery(GET_BOOKING_EMAIL_TEMPLATES);
  const { data: providerData } = useQuery(GET_EMAIL_PROVIDERS);

  const [seedTemplates, { loading: seeding }] = useMutation(
    SEED_BOOKING_TEMPLATES,
    {
      onCompleted: () => refetch(),
    }
  );

  const [updateTemplate] = useMutation(UPDATE_EMAIL_TEMPLATE, {
    onCompleted: () => refetch(),
  });

  const templates: EmailTemplate[] = data?.bookingEmailTemplates ?? [];
  const hasProvider = (providerData?.emailProviders ?? []).length > 0;

  const handleToggleActive = async (template: EmailTemplate) => {
    await updateTemplate({
      variables: { id: template.id, isActive: !template.isActive },
    });
  };

  if (loading) {
    return (
      <Card>
        <div className="animate-pulse space-y-4 p-4">
          <div className="h-4 w-1/3 rounded bg-rough-200" />
          <div className="h-20 rounded bg-rough-100" />
        </div>
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold text-rough-900">
            Booking Email Templates
          </h2>
          <p className="text-sm text-rough-500">
            Configure the emails sent when bookings are confirmed or cancelled.
          </p>
        </div>
      </div>

      {!hasProvider && (
        <div className="rounded-lg border border-amber-200 bg-amber-50 p-4">
          <p className="text-sm font-medium text-amber-800">
            ⚠️ No email provider configured
          </p>
          <p className="mt-1 text-sm text-amber-700">
            Emails will be sent via the default system mailer. For better
            deliverability and tracking, configure an email provider (SendGrid or
            Mailchimp) in your settings.
          </p>
        </div>
      )}

      {templates.length === 0 ? (
        <Card>
          <div className="py-8 text-center">
            <p className="text-lg font-medium text-rough-900">
              No booking templates configured
            </p>
            <p className="mx-auto mt-1 max-w-md text-sm text-rough-500">
              Set up default email templates for booking confirmations and
              cancellations. These will be automatically sent to your golfers.
            </p>
            <Button
              variant="primary"
              className="mt-4"
              onClick={() => seedTemplates()}
              disabled={seeding}
            >
              {seeding ? "Creating..." : "Create Default Templates"}
            </Button>
          </div>
        </Card>
      ) : (
        <div className="grid gap-4 md:grid-cols-2">
          {templates.map((template) => (
            <Card key={template.id} className="relative">
              <div className="space-y-3">
                <div className="flex items-start justify-between">
                  <div>
                    <h3 className="font-medium text-rough-900">
                      {template.name === "booking_confirmation"
                        ? "✅ Booking Confirmation"
                        : "❌ Booking Cancellation"}
                    </h3>
                    <p className="mt-0.5 text-sm text-rough-500">
                      Sent automatically when a booking is{" "}
                      {template.name.includes("confirmation")
                        ? "confirmed"
                        : "cancelled"}
                    </p>
                  </div>
                  <span
                    className={`rounded-full px-2 py-0.5 text-xs font-medium ${
                      template.isActive
                        ? "bg-fairway-100 text-fairway-800"
                        : "bg-rough-100 text-rough-600"
                    }`}
                  >
                    {template.isActive ? "Active" : "Inactive"}
                  </span>
                </div>

                <div className="rounded-md bg-rough-50 p-2">
                  <p className="text-xs font-medium text-rough-500">Subject</p>
                  <p className="mt-0.5 text-sm text-rough-800">
                    {template.subject}
                  </p>
                </div>

                <div className="rounded-md border border-rough-200 bg-white p-2">
                  <div
                    className="max-h-20 overflow-hidden text-xs text-rough-600"
                    dangerouslySetInnerHTML={{
                      __html: template.bodyHtml.substring(0, 300),
                    }}
                  />
                </div>

                <div className="flex items-center justify-between text-xs text-rough-400">
                  <span>Used {template.usageCount} times</span>
                  <span>
                    {template.mergeFields.length} merge fields available
                  </span>
                </div>

                <div className="flex gap-2">
                  <Button
                    variant="secondary"
                    size="sm"
                    onClick={() => setPreviewTemplate(template)}
                  >
                    Preview
                  </Button>
                  {onEditTemplate && (
                    <Button
                      variant="secondary"
                      size="sm"
                      onClick={() => onEditTemplate(template)}
                    >
                      Edit
                    </Button>
                  )}
                  <Button
                    variant="secondary"
                    size="sm"
                    onClick={() => handleToggleActive(template)}
                  >
                    {template.isActive ? "Disable" : "Enable"}
                  </Button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {previewTemplate && (
        <EmailTemplatePreview
          template={previewTemplate}
          onClose={() => setPreviewTemplate(null)}
        />
      )}
    </div>
  );
}
