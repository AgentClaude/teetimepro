require "rails_helper"

RSpec.describe Mutations::InitiateVoiceHandoff do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :staff, organization: organization) }
  let(:voice_call_log) { create(:voice_call_log, organization: organization) }

  let(:query) do
    <<~GQL
      mutation InitiateVoiceHandoff(
        $callSid: String!,
        $callerPhone: String!,
        $callerName: String,
        $reason: VoiceHandoffReasonEnum!,
        $reasonDetail: String,
        $voiceCallLogId: ID
      ) {
        initiateVoiceHandoff(
          callSid: $callSid,
          callerPhone: $callerPhone,
          callerName: $callerName,
          reason: $reason,
          reasonDetail: $reasonDetail,
          voiceCallLogId: $voiceCallLogId
        ) {
          voiceHandoff {
            id
            callSid
            callerPhone
            callerName
            reason
            reasonDetail
            status
            transferTo
            startedAt
            formattedCallerPhone
            callerDisplayName
          }
          transferNumber
          alreadyExists
          errors
        }
      }
    GQL
  end

  describe "initiateVoiceHandoff" do
    let(:valid_variables) do
      {
        callSid: "CA1234567890abcdef",
        callerPhone: "+15551234567",
        callerName: "John Doe",
        reason: "BILLING_INQUIRY",
        reasonDetail: "Customer wants to dispute a charge",
        voiceCallLogId: voice_call_log.id.to_s
      }
    end

    context "when authenticated with valid params" do
      it "creates a voice handoff" do
        context = graphql_context(user: user, organization: organization)
        
        expect {
          result = execute_query(query, variables: valid_variables, context: context)
          expect(result["errors"]).to be_nil
        }.to change { VoiceHandoff.count }.by(1)
      end

      it "returns the created handoff details" do
        context = graphql_context(user: user, organization: organization)
        result = execute_query(query, variables: valid_variables, context: context)
        
        expect(result["errors"]).to be_nil
        
        data = result["data"]["initiateVoiceHandoff"]
        expect(data["voiceHandoff"]["callSid"]).to eq("CA1234567890abcdef")
        expect(data["voiceHandoff"]["callerPhone"]).to eq("+15551234567")
        expect(data["voiceHandoff"]["callerName"]).to eq("John Doe")
        expect(data["voiceHandoff"]["reason"]).to eq("billing_inquiry")
        expect(data["voiceHandoff"]["reasonDetail"]).to eq("Customer wants to dispute a charge")
        expect(data["voiceHandoff"]["status"]).to eq("pending")
        expect(data["voiceHandoff"]["formattedCallerPhone"]).to eq("(555) 123-4567")
        expect(data["voiceHandoff"]["callerDisplayName"]).to eq("John Doe")
        expect(data["transferNumber"]).to be_present
        expect(data["alreadyExists"]).to be false
        expect(data["errors"]).to be_empty
      end

      it "works without optional parameters" do
        variables = valid_variables.except(:callerName, :reasonDetail, :voiceCallLogId)
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_nil
        data = result["data"]["initiateVoiceHandoff"]
        expect(data["voiceHandoff"]["callerName"]).to be_nil
        expect(data["voiceHandoff"]["reasonDetail"]).to be_nil
      end

      it "handles existing handoff for same call_sid" do
        create(:voice_handoff, call_sid: valid_variables[:callSid], organization: organization)
        context = graphql_context(user: user, organization: organization)
        
        expect {
          result = execute_query(query, variables: valid_variables, context: context)
          expect(result["errors"]).to be_nil
        }.not_to change { VoiceHandoff.count }
        
        data = result["data"]["initiateVoiceHandoff"]
        expect(data["alreadyExists"]).to be true
      end

      it "normalizes phone numbers" do
        variables = valid_variables.merge(callerPhone: "5551234567")
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_nil
        data = result["data"]["initiateVoiceHandoff"]
        expect(data["voiceHandoff"]["callerPhone"]).to eq("+15551234567")
      end
    end

    context "when not authenticated" do
      it "returns an authentication error" do
        result = execute_query(query, variables: valid_variables, context: {})
        
        expect(result["errors"]).to be_present
        expect(result["errors"].first["message"]).to include("authenticated")
      end
    end

    context "when user lacks sufficient permissions" do
      it "returns authorization error for customer role" do
        customer = create(:user, :customer, organization: organization)
        context = graphql_context(user: customer, organization: organization)
        
        result = execute_query(query, variables: valid_variables, context: context)
        
        expect(result["errors"]).to be_present
        expect(result["errors"].first["message"]).to include("permission")
      end
    end

    context "with invalid parameters" do
      it "returns errors for missing call_sid" do
        variables = valid_variables.except(:callSid)
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_present
      end

      it "returns errors for missing caller_phone" do
        variables = valid_variables.except(:callerPhone)
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_present
      end

      it "returns errors for missing reason" do
        variables = valid_variables.except(:reason)
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_present
      end

      it "returns errors for invalid reason enum" do
        variables = valid_variables.merge(reason: "INVALID_REASON")
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_present
        expect(result["errors"].first["message"]).to include("INVALID_REASON")
      end
    end

    context "when service returns errors" do
      it "returns service errors in the response" do
        variables = valid_variables.merge(callerPhone: "") # Invalid phone
        context = graphql_context(user: user, organization: organization)
        
        result = execute_query(query, variables: variables, context: context)
        
        expect(result["errors"]).to be_nil # GraphQL doesn't error
        data = result["data"]["initiateVoiceHandoff"]
        expect(data["voiceHandoff"]).to be_nil
        expect(data["errors"]).to be_present
      end
    end
  end
end