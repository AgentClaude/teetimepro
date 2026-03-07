require "rails_helper"

RSpec.describe Mutations::UpdateVoiceHandoff do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :staff, organization: organization) }
  let(:handoff) { create(:voice_handoff, :pending, organization: organization) }

  let(:query) do
    <<~GQL
      mutation UpdateVoiceHandoff(
        $id: ID!,
        $status: VoiceHandoffStatusEnum!,
        $staffName: String,
        $resolutionNotes: String,
        $waitSeconds: Int
      ) {
        updateVoiceHandoff(
          id: $id,
          status: $status,
          staffName: $staffName,
          resolutionNotes: $resolutionNotes,
          waitSeconds: $waitSeconds
        ) {
          voiceHandoff {
            id
            status
            staffName
            resolutionNotes
            waitSeconds
            connectedAt
            completedAt
            durationSeconds
            waitDurationSeconds
            active
          }
          errors
        }
      }
    GQL
  end

  describe "updateVoiceHandoff" do
    context "when authenticated with valid params" do
      it "updates handoff to connected status" do
        variables = {
          id: handoff.id.to_s,
          status: "CONNECTED",
          staffName: "Manager Smith"
        }
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_nil
        data = result["data"]["updateVoiceHandoff"]
        expect(data["voiceHandoff"]["status"]).to eq("connected")
        expect(data["voiceHandoff"]["staffName"]).to eq("Manager Smith")
        expect(data["voiceHandoff"]["connectedAt"]).to be_present
        expect(data["voiceHandoff"]["active"]).to be true
        expect(data["errors"]).to be_empty
      end

      it "updates handoff to completed status" do
        connected_handoff = create(:voice_handoff, :connected, organization: organization)
        variables = {
          id: connected_handoff.id.to_s,
          status: "COMPLETED",
          resolutionNotes: "Issue resolved successfully"
        }
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_nil
        data = result["data"]["updateVoiceHandoff"]
        expect(data["voiceHandoff"]["status"]).to eq("completed")
        expect(data["voiceHandoff"]["resolutionNotes"]).to eq("Issue resolved successfully")
        expect(data["voiceHandoff"]["completedAt"]).to be_present
        expect(data["voiceHandoff"]["active"]).to be false
      end

      it "updates handoff to missed status" do
        variables = {
          id: handoff.id.to_s,
          status: "MISSED",
          resolutionNotes: "No staff available"
        }
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_nil
        data = result["data"]["updateVoiceHandoff"]
        expect(data["voiceHandoff"]["status"]).to eq("missed")
        expect(data["voiceHandoff"]["resolutionNotes"]).to eq("No staff available")
        expect(data["voiceHandoff"]["completedAt"]).to be_present
      end

      it "updates handoff to cancelled status" do
        variables = {
          id: handoff.id.to_s,
          status: "CANCELLED",
          resolutionNotes: "Customer hung up"
        }
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_nil
        data = result["data"]["updateVoiceHandoff"]
        expect(data["voiceHandoff"]["status"]).to eq("cancelled")
        expect(data["voiceHandoff"]["resolutionNotes"]).to eq("Customer hung up")
        expect(data["voiceHandoff"]["completedAt"]).to be_present
      end

      it "calculates wait time automatically" do
        handoff.update!(started_at: 2.minutes.ago)
        variables = {
          id: handoff.id.to_s,
          status: "CONNECTED",
          staffName: "Manager Smith"
        }
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_nil
        data = result["data"]["updateVoiceHandoff"]
        expect(data["voiceHandoff"]["waitDurationSeconds"]).to be_within(5).of(120) # ~2 minutes
      end

      it "accepts manually provided wait time" do
        variables = {
          id: handoff.id.to_s,
          status: "CONNECTED",
          staffName: "Manager Smith",
          waitSeconds: 45
        }
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_nil
        data = result["data"]["updateVoiceHandoff"]
        expect(data["voiceHandoff"]["waitSeconds"]).to eq(45)
        expect(data["voiceHandoff"]["waitDurationSeconds"]).to eq(45)
      end

      it "updates multiple fields at once" do
        variables = {
          id: handoff.id.to_s,
          status: "CONNECTED",
          staffName: "Manager Smith",
          waitSeconds: 30
        }
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_nil
        data = result["data"]["updateVoiceHandoff"]
        expect(data["voiceHandoff"]["status"]).to eq("connected")
        expect(data["voiceHandoff"]["staffName"]).to eq("Manager Smith")
        expect(data["voiceHandoff"]["waitSeconds"]).to eq(30)
      end
    end

    context "when not authenticated" do
      it "returns an authentication error" do
        variables = {
          id: handoff.id.to_s,
          status: "CONNECTED",
          staffName: "Manager Smith"
        }
        
        result = execute_query(query, variables: variables, context: {})
        
        expect(result["errors"]).to be_present
        expect(result["errors"].first["message"]).to include("authenticated")
      end
    end

    context "when user lacks sufficient permissions" do
      it "returns authorization error for customer role" do
        customer = create(:user, :customer, organization: organization)
        variables = {
          id: handoff.id.to_s,
          status: "CONNECTED",
          staffName: "Manager Smith"
        }
        context = graphql_context(user: customer, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_present
        expect(result["errors"].first["message"]).to include("permission")
      end
    end

    context "when handoff belongs to different organization" do
      it "raises RecordNotFound error" do
        other_org = create(:organization)
        other_handoff = create(:voice_handoff, organization: other_org)
        variables = {
          id: other_handoff.id.to_s,
          status: "CONNECTED",
          staffName: "Manager Smith"
        }
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_present
        expect(result["errors"].first["message"]).to include("find")
      end
    end

    context "with invalid parameters" do
      it "returns errors for missing handoff id" do
        variables = {
          status: "CONNECTED",
          staffName: "Manager Smith"
        }
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_present
      end

      it "returns errors for missing status" do
        variables = {
          id: handoff.id.to_s,
          staffName: "Manager Smith"
        }
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_present
      end

      it "returns errors for invalid status enum" do
        variables = {
          id: handoff.id.to_s,
          status: "INVALID_STATUS",
          staffName: "Manager Smith"
        }
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_present
        expect(result["errors"].first["message"]).to include("INVALID_STATUS")
      end
    end

    context "when service validation fails" do
      it "returns service errors for missing staff name on connected" do
        variables = {
          id: handoff.id.to_s,
          status: "CONNECTED"
          # Missing staffName
        }
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_nil # GraphQL doesn't error
        data = result["data"]["updateVoiceHandoff"]
        expect(data["voiceHandoff"]).to be_nil
        expect(data["errors"]).to include("Staff name is required when marking as connected")
      end

      it "returns service errors for missing resolution notes on completed" do
        variables = {
          id: handoff.id.to_s,
          status: "COMPLETED"
          # Missing resolutionNotes
        }
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_nil # GraphQL doesn't error
        data = result["data"]["updateVoiceHandoff"]
        expect(data["voiceHandoff"]).to be_nil
        expect(data["errors"]).to include("Resolution notes are required when marking as completed")
      end

      it "returns service errors for invalid status transitions" do
        completed_handoff = create(:voice_handoff, :completed, organization: organization)
        variables = {
          id: completed_handoff.id.to_s,
          status: "CONNECTED",
          staffName: "Manager Smith"
        }
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_nil # GraphQL doesn't error
        data = result["data"]["updateVoiceHandoff"]
        expect(data["voiceHandoff"]).to be_nil
        expect(data["errors"]).to include("Invalid status transition from completed to connected")
      end
    end
  end
end