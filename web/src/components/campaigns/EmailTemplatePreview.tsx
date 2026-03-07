import { Button } from "../ui/Button";
import { EmailTemplate, TEMPLATE_CATEGORIES } from "../../types/emailProvider";

interface EmailTemplatePreviewProps {
  template: EmailTemplate;
  onClose: () => void;
  onSelect?: (template: EmailTemplate) => void;
}

const SAMPLE_MERGE_DATA: Record<string, string> = {
  first_name: "John",
  last_name: "Doe",
  full_name: "John Doe",
  email: "john.doe@example.com",
  organization_name: "Pine Valley Golf Club",
  unsubscribe_url: "#",
  current_date: new Date().toLocaleDateString("en-US", {
    month: "long",
    day: "numeric",
    year: "numeric",
  }),
};

function renderWithSampleData(text: string): string {
  let rendered = text;
  Object.entries(SAMPLE_MERGE_DATA).forEach(([key, value]) => {
    rendered = rendered.replace(new RegExp(`\\{\\{${key}\\}\\}`, "g"), value);
  });
  return rendered;
}

export function EmailTemplatePreview({
  template,
  onClose,
  onSelect,
}: EmailTemplatePreviewProps) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div className="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-lg bg-white shadow-xl">
        {/* Header */}
        <div className="flex items-center justify-between border-b border-rough-200 px-6 py-4">
          <div>
            <h2 className="text-lg font-semibold text-rough-900">
              {template.name}
            </h2>
            <div className="mt-1 flex items-center gap-2">
              <span className="text-sm text-rough-500">
                {TEMPLATE_CATEGORIES[template.category] ?? template.category}
              </span>
              <span className="text-rough-300">·</span>
              <span className="text-sm text-rough-500">
                Used {template.usageCount} times
              </span>
            </div>
          </div>
          <button
            onClick={onClose}
            className="text-rough-400 hover:text-rough-600"
          >
            ✕
          </button>
        </div>

        {/* Email Preview */}
        <div className="p-6">
          {/* Subject Preview */}
          <div className="mb-4 rounded-md bg-rough-50 p-3">
            <p className="text-xs font-medium uppercase text-rough-500">
              Subject
            </p>
            <p className="mt-1 text-sm font-medium text-rough-900">
              {renderWithSampleData(template.subject)}
            </p>
          </div>

          {/* Body Preview */}
          <div className="rounded-md border border-rough-200 bg-white p-6">
            <div
              className="prose prose-sm max-w-none"
              dangerouslySetInnerHTML={{
                __html: renderWithSampleData(template.bodyHtml),
              }}
            />
          </div>

          {/* Merge Fields */}
          <div className="mt-4">
            <p className="mb-2 text-xs font-medium uppercase text-rough-500">
              Available Merge Fields
            </p>
            <div className="flex flex-wrap gap-1">
              {template.mergeFields.map((field) => (
                <span
                  key={field}
                  className="rounded border border-rough-200 bg-rough-50 px-2 py-0.5 font-mono text-xs text-rough-600"
                >
                  {field}
                </span>
              ))}
            </div>
          </div>

          {/* Sample Data Note */}
          <p className="mt-3 text-xs text-rough-400">
            Preview shown with sample data. Actual values will be replaced when
            sending.
          </p>
        </div>

        {/* Footer */}
        <div className="flex justify-end gap-2 border-t border-rough-200 px-6 py-4">
          <Button variant="secondary" onClick={onClose}>
            Close
          </Button>
          {onSelect && (
            <Button variant="primary" onClick={() => onSelect(template)}>
              Use This Template
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}
