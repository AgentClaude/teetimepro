import { useState } from "react";
import { Button } from "../components/ui/Button";
import { CampaignList, CreateCampaignModal } from "../components/campaigns";

export default function CampaignsPage() {
  const [showCreateModal, setShowCreateModal] = useState(false);

  return (
    <div className="mx-auto max-w-4xl px-4 py-8">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-rough-900">SMS Campaigns</h1>
          <p className="mt-1 text-sm text-rough-600">
            Send targeted SMS messages to your golfers
          </p>
        </div>
        <Button onClick={() => setShowCreateModal(true)}>
          + New Campaign
        </Button>
      </div>

      <CampaignList />

      <CreateCampaignModal
        isOpen={showCreateModal}
        onClose={() => setShowCreateModal(false)}
      />
    </div>
  );
}
