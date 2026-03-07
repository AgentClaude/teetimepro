import { useState } from "react";
import { useMutation } from "@apollo/client";
import { CREATE_EMAIL_TEMPLATE } from "../../graphql/mutations";
import { GET_EMAIL_TEMPLATES } from "../../graphql/queries";
import { Button } from "../ui/Button";
import { Input } from "../ui/Input";
import {
  TEMPLATE_CATEGORIES,
  MERGE_FIELD_OPTIONS,
  TemplateCategory,
  CreateEmailTemplateInput,
} from "../../types/emailProvider";

interface CreateEmailTemplateModalProps {
  onClose: () => void;
}

export function CreateEmailTemplateModal({
  onClose,
}: CreateEmailTemplateModalProps) {
  const [createTemplate, { loading }] = useMutation(CREATE_EMAIL_TEMPLATE, {
    refetchQueries: [{ query: GET_EMAIL_TEMPLATES }],
  });

  const [formData, setFormData] = useState<CreateEmailTemplateInput>({
    name: "",
    subject: "",
    bodyHtml: "",
    bodyText: "",
    category: "general",
  });
  const [errors, setErrors] = useState<string[]>([]);
  const [showPreview, setShowPreview] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrors([]);

    try {
      const { data } = await createTemplate({ variables: formData });

      if (data?.createEmailTemplate.errors?.length > 0) {
        setErrors(data.createEmailTemplate.errors);
      } else {
        onClose();
      }
    } catch (err) {
      setErrors(["Failed to create template"]);
    }
  };

  const insertMergeField = (field: string) => {
    setFormData((prev) => ({
      ...prev,
      bodyHtml: prev.bodyHtml + field,
    }));
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div className="max-h-[90vh] w-full max-w-3xl overflow-y-auto rounded-lg bg-white p-6 shadow-xl">
        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-lg font-semibold text-rough-900">
            Create Email Template
          </h2>
          <button
            onClick={onClose}
            className="text-rough-400 hover:text-rough-600"
          >
            ✕
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {errors.length > 0 && (
            <div className="rounded-md bg-red-50 p-3">
              {errors.map((err, i) => (
                <p key={i} className="text-sm text-red-700">
                  {err}
                </p>
              ))}
            </div>
          )}

          <div className="grid gap-4 md:grid-cols-2">
            <div>
              <label className="mb-1 block text-sm font-medium text-rough-700">
                Template Name
              </label>
              <Input
                placeholder="Welcome Back Campaign"
                value={formData.name}
                onChange={(e) =>
                  setFormData({ ...formData, name: e.target.value })
                }
                required
              />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium text-rough-700">
                Category
              </label>
              <select
                className="w-full rounded-md border border-rough-300 px-3 py-2 text-sm"
                value={formData.category}
                onChange={(e) =>
                  setFormData({ ...formData, category: e.target.value })
                }
              >
                {(
                  Object.entries(TEMPLATE_CATEGORIES) as [
                    TemplateCategory,
                    string,
                  ][]
                ).map(([key, label]) => (
                  <option key={key} value={key}>
                    {label}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label className="mb-1 block text-sm font-medium text-rough-700">
              Subject Line
            </label>
            <Input
              placeholder="Hey {{first_name}}, we have a special offer!"
              value={formData.subject}
              onChange={(e) =>
                setFormData({ ...formData, subject: e.target.value })
              }
              required
            />
            <p className="mt-1 text-xs text-rough-500">
              Use merge fields like {"{{first_name}}"} for personalization.
            </p>
          </div>

          {/* Merge Fields */}
          <div>
            <label className="mb-1 block text-sm font-medium text-rough-700">
              Insert Merge Field
            </label>
            <div className="flex flex-wrap gap-1">
              {MERGE_FIELD_OPTIONS.map((field) => (
                <button
                  key={field.value}
                  type="button"
                  className="rounded border border-rough-200 bg-rough-50 px-2 py-1 text-xs text-rough-700 hover:bg-rough-100"
                  onClick={() => insertMergeField(field.value)}
                >
                  {field.label}
                </button>
              ))}
            </div>
          </div>

          <div>
            <div className="mb-1 flex items-center justify-between">
              <label className="block text-sm font-medium text-rough-700">
                Email Body (HTML)
              </label>
              <button
                type="button"
                className="text-xs text-fairway-600 hover:text-fairway-700"
                onClick={() => setShowPreview(!showPreview)}
              >
                {showPreview ? "Edit" : "Preview"}
              </button>
            </div>
            {showPreview ? (
              <div className="min-h-[200px] rounded-md border border-rough-200 bg-white p-4">
                <div
                  dangerouslySetInnerHTML={{
                    __html: formData.bodyHtml.replace(
                      /\{\{(\w+)\}\}/g,
                      '<span class="rounded bg-yellow-100 px-1">[$1]</span>'
                    ),
                  }}
                />
              </div>
            ) : (
              <textarea
                className="w-full rounded-md border border-rough-300 p-3 font-mono text-sm"
                rows={10}
                placeholder="<h1>Hello {{first_name}}</h1><p>We miss you at the course...</p>"
                value={formData.bodyHtml}
                onChange={(e) =>
                  setFormData({ ...formData, bodyHtml: e.target.value })
                }
                required
              />
            )}
          </div>

          <div className="flex justify-end gap-2 pt-2">
            <Button type="button" variant="secondary" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit" variant="primary" loading={loading}>
              Create Template
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
