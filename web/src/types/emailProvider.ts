export interface EmailProvider {
  id: string;
  providerType: "sendgrid" | "mailchimp";
  fromEmail: string;
  fromName: string | null;
  isActive: boolean;
  isDefault: boolean;
  verificationStatus: "pending" | "verified" | "failed";
  lastVerifiedAt: string | null;
  maskedApiKey: string;
  settings: Record<string, unknown>;
  createdAt: string;
  updatedAt: string;
}

export interface EmailTemplate {
  id: string;
  name: string;
  subject: string;
  bodyHtml: string;
  bodyText: string | null;
  category: TemplateCategory;
  isActive: boolean;
  mergeFields: string[];
  usageCount: number;
  createdAt: string;
  updatedAt: string;
  createdBy: {
    id: string;
    fullName: string;
  };
}

export type TemplateCategory =
  | "general"
  | "re-engagement"
  | "promotion"
  | "newsletter"
  | "transactional";

export interface ConfigureEmailProviderInput {
  providerType: string;
  apiKey: string;
  fromEmail: string;
  fromName?: string;
  isDefault?: boolean;
  settings?: Record<string, unknown>;
}

export interface CreateEmailTemplateInput {
  name: string;
  subject: string;
  bodyHtml: string;
  bodyText?: string;
  category?: string;
  mergeFields?: string[];
}

export interface UpdateEmailTemplateInput {
  id: string;
  name?: string;
  subject?: string;
  bodyHtml?: string;
  bodyText?: string;
  category?: string;
  isActive?: boolean;
}

export const MERGE_FIELD_OPTIONS = [
  { value: "{{first_name}}", label: "First Name" },
  { value: "{{last_name}}", label: "Last Name" },
  { value: "{{full_name}}", label: "Full Name" },
  { value: "{{email}}", label: "Email" },
  { value: "{{organization_name}}", label: "Organization Name" },
  { value: "{{unsubscribe_url}}", label: "Unsubscribe URL" },
  { value: "{{current_date}}", label: "Current Date" },
] as const;

export const TEMPLATE_CATEGORIES: Record<TemplateCategory, string> = {
  general: "General",
  "re-engagement": "Re-engagement",
  promotion: "Promotion",
  newsletter: "Newsletter",
  transactional: "Transactional",
};

export const PROVIDER_LABELS: Record<string, string> = {
  sendgrid: "SendGrid",
  mailchimp: "Mailchimp (Mandrill)",
};
