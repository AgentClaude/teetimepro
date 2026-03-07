require "rails_helper"

RSpec.describe "Customer Detail Query" do
  let(:organization) { create(:organization) }
  let(:manager) { create(:user, :manager, organization: organization) }
  let(:golfer) { create(:user, organization: organization, role: :golfer, phone: "555-123-4567") }
  let(:course) { create(:course, organization: organization) }

  let(:query) do
    <<~GQL
      query GetCustomer($id: ID!) {
        customer(id: $id) {
          id
          email
          firstName
          lastName
          fullName
          phone
          role
          bookingsCount
          createdAt
          updatedAt
          upcomingBookings {
            id
            confirmationCode
            status
            playersCount
            totalCents
            teeTime {
              id
              startsAt
              formattedTime
              teeSheet {
                date
                course {
                  id
                  name
                }
              }
            }
          }
          pastBookings {
            id
            confirmationCode
            status
            playersCount
            totalCents
            teeTime {
              id
              startsAt
              formattedTime
              teeSheet {
                date
                course {
                  id
                  name
                }
              }
            }
          }
          membership {
            id
            tier
            status
            daysRemaining
            accountBalanceCents
            creditLimitCents
            availableCreditCents
          }
          loyaltyAccount {
            id
            pointsBalance
            lifetimePoints
            tier
            tierName
            pointsNeededForNextTier
            recentTransactions {
              id
              transactionType
              points
              description
              balanceAfter
              createdAt
            }
          }
          golferProfile {
            id
            handicapIndex
          }
        }
      }
    GQL
  end

  describe "customer" do
    context "when authenticated as a manager" do
      it "returns basic customer info" do
        context = graphql_context(user: manager)
        result = execute_query(query, variables: { id: golfer.id.to_s }, context: context)
        data = graphql_response(result)

        customer = data.dig("data", "customer")
        expect(customer).not_to be_nil
        expect(customer["fullName"]).to eq(golfer.full_name)
        expect(customer["email"]).to eq(golfer.email)
        expect(customer["phone"]).to eq("555-123-4567")
        expect(customer["role"]).to eq("golfer")
      end

      it "returns upcoming bookings with course info" do
        tee_sheet = create(:tee_sheet, course: course, date: 3.days.from_now.to_date)
        tee_time = create(:tee_time, tee_sheet: tee_sheet, starts_at: 3.days.from_now)
        booking = create(:booking, user: golfer, tee_time: tee_time, status: :confirmed)

        context = graphql_context(user: manager)
        result = execute_query(query, variables: { id: golfer.id.to_s }, context: context)
        data = graphql_response(result)

        upcoming = data.dig("data", "customer", "upcomingBookings")
        expect(upcoming.length).to eq(1)
        expect(upcoming.first["confirmationCode"]).to eq(booking.confirmation_code)
        expect(upcoming.first.dig("teeTime", "teeSheet", "course", "name")).to eq(course.name)
      end

      it "returns past bookings" do
        tee_sheet = create(:tee_sheet, course: course, date: 3.days.ago.to_date)
        tee_time = create(:tee_time, tee_sheet: tee_sheet, starts_at: 3.days.ago)
        create(:booking, user: golfer, tee_time: tee_time, status: :completed)

        context = graphql_context(user: manager)
        result = execute_query(query, variables: { id: golfer.id.to_s }, context: context)
        data = graphql_response(result)

        past = data.dig("data", "customer", "pastBookings")
        expect(past.length).to eq(1)
        expect(past.first["status"]).to eq("completed")
      end

      it "excludes cancelled bookings from upcoming" do
        tee_sheet = create(:tee_sheet, course: course, date: 5.days.from_now.to_date)
        tee_time = create(:tee_time, tee_sheet: tee_sheet, starts_at: 5.days.from_now)
        create(:booking, :cancelled, user: golfer, tee_time: tee_time)

        context = graphql_context(user: manager)
        result = execute_query(query, variables: { id: golfer.id.to_s }, context: context)
        data = graphql_response(result)

        upcoming = data.dig("data", "customer", "upcomingBookings")
        expect(upcoming).to be_empty
      end

      it "returns membership info when present" do
        create(:membership, organization: organization, user: golfer, tier: :gold, status: :active)

        context = graphql_context(user: manager)
        result = execute_query(query, variables: { id: golfer.id.to_s }, context: context)
        data = graphql_response(result)

        membership = data.dig("data", "customer", "membership")
        expect(membership).not_to be_nil
        expect(membership["tier"]).to eq("gold")
        expect(membership["status"]).to eq("active")
      end

      it "returns nil membership when none exists" do
        context = graphql_context(user: manager)
        result = execute_query(query, variables: { id: golfer.id.to_s }, context: context)
        data = graphql_response(result)

        expect(data.dig("data", "customer", "membership")).to be_nil
      end

      it "returns loyalty account with recent transactions" do
        loyalty_account = create(:loyalty_account, :gold_tier, organization: organization, user: golfer)
        create(:loyalty_transaction,
          loyalty_account: loyalty_account,
          transaction_type: :earn,
          points: 150,
          description: "Round completed",
          balance_after: 1650
        )

        context = graphql_context(user: manager)
        result = execute_query(query, variables: { id: golfer.id.to_s }, context: context)
        data = graphql_response(result)

        loyalty = data.dig("data", "customer", "loyaltyAccount")
        expect(loyalty).not_to be_nil
        expect(loyalty["tier"]).to eq("gold")
        expect(loyalty["pointsBalance"]).to eq(1500)

        transactions = loyalty["recentTransactions"]
        expect(transactions.length).to eq(1)
        expect(transactions.first["points"]).to eq(150)
        expect(transactions.first["description"]).to eq("Round completed")
      end

      it "returns nil loyalty account when not enrolled" do
        context = graphql_context(user: manager)
        result = execute_query(query, variables: { id: golfer.id.to_s }, context: context)
        data = graphql_response(result)

        expect(data.dig("data", "customer", "loyaltyAccount")).to be_nil
      end

      it "returns golfer profile when present" do
        create(:golfer_profile, user: golfer, handicap_index: 12.4)

        context = graphql_context(user: manager)
        result = execute_query(query, variables: { id: golfer.id.to_s }, context: context)
        data = graphql_response(result)

        profile = data.dig("data", "customer", "golferProfile")
        expect(profile).not_to be_nil
        expect(profile["handicapIndex"]).to eq(12.4)
      end

      it "returns bookings count" do
        tee_sheet = create(:tee_sheet, course: course, date: 1.day.ago.to_date)
        tee_time = create(:tee_time, tee_sheet: tee_sheet, starts_at: 1.day.ago)
        create_list(:booking, 3, user: golfer, tee_time: tee_time)

        context = graphql_context(user: manager)
        result = execute_query(query, variables: { id: golfer.id.to_s }, context: context)
        data = graphql_response(result)

        expect(data.dig("data", "customer", "bookingsCount")).to eq(3)
      end
    end
  end
end
