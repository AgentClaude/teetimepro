import { useState } from "react";
import { useQuery } from "@apollo/client";
import { GET_EMAIL_TEMPLATES } from "../../graphql/queries";
import { Card } from "../ui/Card";
import { Button } from "../ui/Button";
import {
  EmailTemplate,
  TemplateCategory,
  TEMPLATE_CATEGORIES,
} from "../../types/emailProvider";
import { CreateEmailTemplateModal } from "./CreateEmailTemplateModal";
import { EmailTemplatePreview } from "./EmailTemplatePreview";

export function EmailTemplateList() {
  const [categoryFilter, setCategoryFilter] = useState<string | undefined>();
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [previewTemplate, setPreviewTemplate] = useState<EmailTemplate | null>(
    null
  );

  const { data, loading, error } = useQuery(GET_EMAIL_TEMPLATES, {
    variables: { category: categoryFilter },
  });

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
          Error loading templates: {error.message}
        </p>
      </Card>
    );
  }

  const templates: EmailTemplate[] = data?.emailTemplates ?? [];

  const getCategoryBadge = (category: TemplateCategory) => {
    const colors: Record<string, string> = {
      general: "bg-gray-100 text-gray-700",
      "re-engagement": "bg-orange-100 text-orange-700",
      promotion: "bg-purple-100 text-purple-700",
      newsletter: "bg-blue-100 text-blue-700",
      transactional: "bg-green-100 text-green-700",
    };

    return (
      <span
        className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${colors[category] ?? colors.general}`}
      >
        {TEMPLATE_CATEGORIES[category] ?? category}
      </span>
    );
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold text-rough-900">
            Email Templates
          </h2>
          <p className="text-sm text-rough-500">
            Reusable templates with merge fields for personalized campaigns.
          </p>
        </div>
        <Button
          variant="primary"
          size="sm"
          onClick={() => setShowCreateModal(true)}
        >
          + New Template
        </Button>
      </div>

      {/* Category Filter */}
      <div className="flex gap-2">
        <button
          className={`rounded-full px-3 py-1 text-sm ${
            !categoryFilter
              ? "bg-fairway-500 text-white"
              : "bg-rough-100 text-rough-700 hover:bg-rough-200"
          }`}
          onClick={() => setCategoryFilter(undefined)}
        >
          All
        </button>
        {(
          Object.entries(TEMPLATE_CATEGORIES) as [TemplateCategory, string][]
        ).map(([key, label]) => (
          <button
            key={key}
            className={`rounded-full px-3 py-1 text-sm ${
              categoryFilter === key
                ? "bg-fairway-500 text-white"
                : "bg-rough-100 text-rough-700 hover:bg-rough-200"
            }`}
            onClick={() => setCategoryFilter(key)}
          >
            {label}
          </button>
        ))}
      </div>

      {templates.length === 0 ? (
        <Card>
          <div className="py-8 text-center">
            <p className="text-lg font-medium text-rough-900">
              No templates yet
            </p>
            <p className="mt-1 text-sm text-rough-500">
              Create reusable email templates for your campaigns.
            </p>
          </div>
        </Card>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {templates.map((template) => (
            <Card key={template.id} className="cursor-pointer hover:shadow-md transition-shadow">
              <div
                onClick={() => setPreviewTemplate(template)}
              >
                <div className="flex items-start justify-between">
                  <h3 className="font-medium text-rough-900">
                    {template.name}
                  </h3>
                  {getCategoryBadge(template.category)}
                </div>
                <p className="mt-1 text-sm text-rough-600 line-clamp-1">
                  Subject: {template.subject}
                </p>
                <div className="mt-3 rounded-md border border-rough-200 bg-rough-50 p-2">
                  <div
                    className="max-h-24 overflow-hidden text-xs text-rough-600"
                    dangerouslySetInnerHTML={{
                      __html: template.bodyHtml.substring(0, 200),
                    }}
                  />
                </div>
                <div className="mt-3 flex items-center justify-between text-xs text-rough-500">
                  <span>Used {template.usageCount} times</span>
                  <span>
                    {new Date(template.createdAt).toLocaleDateString()}
                  </span>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {showCreateModal && (
        <CreateEmailTemplateModal
          onClose={() => setShowCreateModal(false)}
        />
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
