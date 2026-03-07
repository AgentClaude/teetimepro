import { useState } from "react";
import { useQuery, useMutation } from "@apollo/client";
import { GET_EMAIL_PROVIDERS } from "../../graphql/queries";
import { CONFIGURE_EMAIL_PROVIDER } from "../../graphql/mutations";
import { Card } from "../ui/Card";
import { Button } from "../ui/Button";
import { Input } from "../ui/Input";
import {
  EmailProvider,
  PROVIDER_LABELS,
  ConfigureEmailProviderInput,
} from "../../types/emailProvider";

type ProviderType = "sendgrid" | "mailchimp";

export function EmailProviderSettings() {
  const { data, loading, error } = useQuery(GET_EMAIL_PROVIDERS);
  const [configureProvider, { loading: saving }] = useMutation(
    CONFIGURE_EMAIL_PROVIDER,
    { refetchQueries: [{ query: GET_EMAIL_PROVIDERS }] }
  );

  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState<ConfigureEmailProviderInput>({
    providerType: "sendgrid",
    apiKey: "",
    fromEmail: "",
    fromName: "",
  });
  const [formErrors, setFormErrors] = useState<string[]>([]);

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-fairway-500 border-t-transparent" />
      </div>
    );
  }

  if (error) {
    return (
      <Card>
        <p className="text-red-600">
          Error loading email providers: {error.message}
        </p>
      </Card>
    );
  }

  const providers: EmailProvider[] = data?.emailProviders ?? [];

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormErrors([]);

    try {
      const { data: result } = await configureProvider({
        variables: formData,
      });

      if (result?.configureEmailProvider.errors?.length > 0) {
        setFormErrors(result.configureEmailProvider.errors);
      } else {
        setShowForm(false);
        setFormData({
          providerType: "sendgrid",
          apiKey: "",
          fromEmail: "",
          fromName: "",
        });
      }
    } catch (err) {
      setFormErrors(["Failed to configure provider"]);
    }
  };

  const getStatusBadge = (status: string) => {
    const styles: Record<string, string> = {
      verified:
        "bg-green-100 text-green-800 border-green-200",
      pending:
        "bg-yellow-100 text-yellow-800 border-yellow-200",
      failed: "bg-red-100 text-red-800 border-red-200",
    };

    const labels: Record<string, string> = {
      verified: "✅ Verified",
      pending: "⏳ Pending",
      failed: "❌ Failed",
    };

    return (
      <span
        className={`inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-medium ${styles[status] ?? styles.pending}`}
      >
        {labels[status] ?? status}
      </span>
    );
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold text-rough-900">
            Email Providers
          </h2>
          <p className="text-sm text-rough-500">
            Configure SendGrid or Mailchimp for email delivery and tracking.
          </p>
        </div>
        {!showForm && (
          <Button
            variant="primary"
            size="sm"
            onClick={() => setShowForm(true)}
          >
            + Add Provider
          </Button>
        )}
      </div>

      {providers.length > 0 && (
        <div className="grid gap-4 md:grid-cols-2">
          {providers.map((provider) => (
            <Card key={provider.id}>
              <div className="flex items-start justify-between">
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className="font-medium text-rough-900">
                      {PROVIDER_LABELS[provider.providerType] ??
                        provider.providerType}
                    </h3>
                    {getStatusBadge(provider.verificationStatus)}
                    {provider.isDefault && (
                      <span className="inline-flex items-center rounded-full bg-blue-100 px-2 py-0.5 text-xs font-medium text-blue-800">
                        Default
                      </span>
                    )}
                  </div>
                  <div className="mt-2 space-y-1 text-sm text-rough-600">
                    <p>
                      <span className="font-medium">From:</span>{" "}
                      {provider.fromName
                        ? `${provider.fromName} <${provider.fromEmail}>`
                        : provider.fromEmail}
                    </p>
                    <p>
                      <span className="font-medium">API Key:</span>{" "}
                      <code className="rounded bg-rough-100 px-1 text-xs">
                        {provider.maskedApiKey}
                      </code>
                    </p>
                    {provider.lastVerifiedAt && (
                      <p>
                        <span className="font-medium">Last verified:</span>{" "}
                        {new Date(provider.lastVerifiedAt).toLocaleDateString()}
                      </p>
                    )}
                  </div>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {providers.length === 0 && !showForm && (
        <Card>
          <div className="py-8 text-center">
            <p className="text-lg font-medium text-rough-900">
              No email providers configured
            </p>
            <p className="mt-1 text-sm text-rough-500">
              Connect SendGrid or Mailchimp to send email campaigns with
              delivery tracking.
            </p>
            <Button
              variant="primary"
              className="mt-4"
              onClick={() => setShowForm(true)}
            >
              Configure Provider
            </Button>
          </div>
        </Card>
      )}

      {showForm && (
        <Card>
          <h3 className="mb-4 font-medium text-rough-900">
            Configure Email Provider
          </h3>
          <form onSubmit={handleSubmit} className="space-y-4">
            {formErrors.length > 0 && (
              <div className="rounded-md bg-red-50 p-3">
                {formErrors.map((err, i) => (
                  <p key={i} className="text-sm text-red-700">
                    {err}
                  </p>
                ))}
              </div>
            )}

            <div>
              <label className="mb-1 block text-sm font-medium text-rough-700">
                Provider
              </label>
              <div className="flex gap-3">
                {(["sendgrid", "mailchimp"] as ProviderType[]).map((type) => (
                  <label
                    key={type}
                    className={`flex cursor-pointer items-center gap-2 rounded-lg border px-4 py-2 ${
                      formData.providerType === type
                        ? "border-fairway-500 bg-fairway-50"
                        : "border-rough-200"
                    }`}
                  >
                    <input
                      type="radio"
                      name="providerType"
                      value={type}
                      checked={formData.providerType === type}
                      onChange={(e) =>
                        setFormData({
                          ...formData,
                          providerType: e.target.value,
                        })
                      }
                      className="hidden"
                    />
                    <span className="text-sm font-medium">
                      {PROVIDER_LABELS[type]}
                    </span>
                  </label>
                ))}
              </div>
            </div>

            <div>
              <label className="mb-1 block text-sm font-medium text-rough-700">
                API Key
              </label>
              <Input
                type="password"
                placeholder={
                  formData.providerType === "sendgrid"
                    ? "SG.xxxxxxxx..."
                    : "mc-xxxxxxxx..."
                }
                value={formData.apiKey}
                onChange={(e) =>
                  setFormData({ ...formData, apiKey: e.target.value })
                }
                required
              />
              <p className="mt-1 text-xs text-rough-500">
                {formData.providerType === "sendgrid"
                  ? "Find your API key at Settings → API Keys in SendGrid."
                  : "Use your Mandrill API key from Mailchimp Transactional."}
              </p>
            </div>

            <div className="grid gap-4 md:grid-cols-2">
              <div>
                <label className="mb-1 block text-sm font-medium text-rough-700">
                  From Email
                </label>
                <Input
                  type="email"
                  placeholder="noreply@yourgolfcourse.com"
                  value={formData.fromEmail}
                  onChange={(e) =>
                    setFormData({ ...formData, fromEmail: e.target.value })
                  }
                  required
                />
              </div>
              <div>
                <label className="mb-1 block text-sm font-medium text-rough-700">
                  From Name
                </label>
                <Input
                  placeholder="Your Golf Course"
                  value={formData.fromName ?? ""}
                  onChange={(e) =>
                    setFormData({ ...formData, fromName: e.target.value })
                  }
                />
              </div>
            </div>

            <div className="flex gap-2">
              <Button type="submit" variant="primary" loading={saving}>
                Save & Verify
              </Button>
              <Button
                type="button"
                variant="secondary"
                onClick={() => setShowForm(false)}
              >
                Cancel
              </Button>
            </div>
          </form>
        </Card>
      )}
    </div>
  );
}
