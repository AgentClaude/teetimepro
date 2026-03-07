import { useState } from "react";
import { Modal } from "../ui/Modal";
import { Input } from "../ui/Input";
import { Button } from "../ui/Button";
import type { MarketplaceProvider, Course } from "../../types";

interface ConnectMarketplaceModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConnect: (data: ConnectMarketplaceData) => void;
  courses: Course[];
  connecting?: boolean;
}

export interface ConnectMarketplaceData {
  courseId: string;
  provider: MarketplaceProvider;
  apiKey: string;
  apiSecret: string;
  externalCourseId: string;
}

const providers: Array<{ value: MarketplaceProvider; label: string; description: string }> = [
  {
    value: "golfnow",
    label: "GolfNow",
    description: "Syndicate tee times to GolfNow, the largest online tee time marketplace",
  },
  {
    value: "teeoff",
    label: "TeeOff",
    description: "List discounted tee times on TeeOff.com",
  },
];

export function ConnectMarketplaceModal({
  isOpen,
  onClose,
  onConnect,
  courses,
  connecting = false,
}: ConnectMarketplaceModalProps) {
  const [selectedProvider, setSelectedProvider] = useState<MarketplaceProvider | null>(null);
  const [courseId, setCourseId] = useState("");
  const [apiKey, setApiKey] = useState("");
  const [apiSecret, setApiSecret] = useState("");
  const [externalCourseId, setExternalCourseId] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedProvider || !courseId || !apiKey) return;

    onConnect({
      courseId,
      provider: selectedProvider,
      apiKey,
      apiSecret,
      externalCourseId,
    });
  };

  const resetForm = () => {
    setSelectedProvider(null);
    setCourseId("");
    setApiKey("");
    setApiSecret("");
    setExternalCourseId("");
  };

  const handleClose = () => {
    resetForm();
    onClose();
  };

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Connect Marketplace">
      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Provider Selection */}
        <div>
          <label className="block text-sm font-medium text-rough-700 mb-2">
            Select Marketplace
          </label>
          <div className="grid grid-cols-2 gap-3">
            {providers.map((provider) => (
              <button
                key={provider.value}
                type="button"
                onClick={() => setSelectedProvider(provider.value)}
                className={`rounded-lg border-2 p-4 text-left transition-colors ${
                  selectedProvider === provider.value
                    ? "border-primary-500 bg-primary-50"
                    : "border-rough-200 hover:border-rough-300"
                }`}
              >
                <div className="font-semibold text-rough-900">{provider.label}</div>
                <div className="mt-1 text-xs text-rough-500">{provider.description}</div>
              </button>
            ))}
          </div>
        </div>

        {selectedProvider && (
          <>
            {/* Course Selection */}
            <div>
              <label className="block text-sm font-medium text-rough-700 mb-1">
                Course
              </label>
              <select
                value={courseId}
                onChange={(e) => setCourseId(e.target.value)}
                className="w-full rounded-md border border-rough-300 px-3 py-2 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
                required
              >
                <option value="">Select a course...</option>
                {courses.map((course) => (
                  <option key={course.id} value={course.id}>
                    {course.name}
                  </option>
                ))}
              </select>
            </div>

            {/* API Credentials */}
            <div>
              <Input
                label="API Key"
                value={apiKey}
                onChange={(e) => setApiKey(e.target.value)}
                placeholder={`Your ${selectedProvider === "golfnow" ? "GolfNow" : "TeeOff"} API key`}
                required
              />
            </div>

            <div>
              <Input
                label="API Secret (optional)"
                type="password"
                value={apiSecret}
                onChange={(e) => setApiSecret(e.target.value)}
                placeholder="API secret or token"
              />
            </div>

            <div>
              <Input
                label={`External Course/Facility ID (optional)`}
                value={externalCourseId}
                onChange={(e) => setExternalCourseId(e.target.value)}
                placeholder={selectedProvider === "golfnow" ? "GolfNow Course ID" : "TeeOff Facility ID"}
              />
              <p className="mt-1 text-xs text-rough-500">
                If left blank, we'll look up your course automatically.
              </p>
            </div>

            <div className="flex justify-end space-x-3 pt-4 border-t border-rough-200">
              <Button variant="secondary" onClick={handleClose} type="button">
                Cancel
              </Button>
              <Button
                variant="primary"
                type="submit"
                disabled={connecting || !courseId || !apiKey}
              >
                {connecting ? "Connecting..." : "Connect"}
              </Button>
            </div>
          </>
        )}
      </form>
    </Modal>
  );
}
