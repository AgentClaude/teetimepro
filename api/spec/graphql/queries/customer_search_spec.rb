require "rails_helper"

RSpec.describe "Customer Search and Filtering" do
  let(:organization) { create(:organization) }
  let(:manager) { create(:user, :manager, organization: organization) }

  let(:query) do
    <<~GQL
      query GetCustomers(
        $search: String
        $role: String
        $membershipTier: String
        $loyaltyTier: String
        $minBookings: Int
        $maxBookings: Int
        $sortBy: String
        $sortDir: String
        $page: Int
        $perPage: Int
      ) {
        customers(
          search: $search
          role: $role
          membershipTier: $membershipTier
          loyaltyTier: $loyaltyTier
          minBookings: $minBookings
          maxBookings: $maxBookings
          sortBy: $sortBy
          sortDir: $sortDir
          page: $page
          perPage: $perPage
        ) {
          nodes {
            id
            fullName
            email
            role
            bookingsCount
          }
          totalCount
          page
          perPage
          totalPages
        }
      }
    GQL
  end

  def execute(variables = {})
    context = graphql_context(user: manager)
    result = execute_query(query, variables: variables, context: context)
    graphql_response(result)
  end

  describe "text search" do
    let!(:alice) { create(:user, organization: organization, first_name: "Alice", last_name: "Johnson", email: "alice@example.com") }
    let!(:bob) { create(:user, organization: organization, first_name: "Bob", last_name: "Smith", email: "bob@example.com") }

    it "searches by first name" do
      data = execute(search: "Alice")
      nodes = data.dig("data", "customers", "nodes")
      expect(nodes.length).to eq(1)
      expect(nodes.first["fullName"]).to eq("Alice Johnson")
    end

    it "searches by email" do
      data = execute(search: "bob@")
      nodes = data.dig("data", "customers", "nodes")
      expect(nodes.length).to eq(1)
      expect(nodes.first["email"]).to eq("bob@example.com")
    end

    it "returns all when no search" do
      data = execute
      total = data.dig("data", "customers", "totalCount")
      # includes manager + alice + bob
      expect(total).to be >= 3
    end
  end

  describe "role filtering" do
    let!(:golfer) { create(:user, organization: organization, role: :golfer) }
    let!(:staff) { create(:user, organization: organization, role: :staff) }

    it "filters by role" do
      data = execute(role: "golfer")
      nodes = data.dig("data", "customers", "nodes")
      roles = nodes.map { |n| n["role"] }.uniq
      expect(roles).to eq(["golfer"])
    end
  end

  describe "membership tier filtering" do
    let!(:gold_member) { create(:user, organization: organization, role: :golfer) }
    let!(:non_member) { create(:user, organization: organization, role: :golfer) }

    before do
      create(:membership, organization: organization, user: gold_member, tier: :gold, status: :active)
    end

    it "filters by membership tier" do
      data = execute(membershipTier: "gold")
      nodes = data.dig("data", "customers", "nodes")
      ids = nodes.map { |n| n["id"] }
      expect(ids).to include(gold_member.id.to_s)
      expect(ids).not_to include(non_member.id.to_s)
    end

    it "filters for no membership" do
      data = execute(membershipTier: "none")
      ids = data.dig("data", "customers", "nodes").map { |n| n["id"] }
      expect(ids).not_to include(gold_member.id.to_s)
      expect(ids).to include(non_member.id.to_s)
    end
  end

  describe "loyalty tier filtering" do
    let!(:loyalty_user) { create(:user, organization: organization, role: :golfer) }
    let!(:no_loyalty) { create(:user, organization: organization, role: :golfer) }

    before do
      create(:loyalty_account, :gold_tier, organization: organization, user: loyalty_user)
    end

    it "filters by loyalty tier" do
      data = execute(loyaltyTier: "gold")
      ids = data.dig("data", "customers", "nodes").map { |n| n["id"] }
      expect(ids).to include(loyalty_user.id.to_s)
      expect(ids).not_to include(no_loyalty.id.to_s)
    end

    it "filters for not enrolled" do
      data = execute(loyaltyTier: "none")
      ids = data.dig("data", "customers", "nodes").map { |n| n["id"] }
      expect(ids).not_to include(loyalty_user.id.to_s)
      expect(ids).to include(no_loyalty.id.to_s)
    end
  end

  describe "bookings count filtering" do
    let!(:frequent) { create(:user, organization: organization, role: :golfer) }
    let!(:occasional) { create(:user, organization: organization, role: :golfer) }
    let(:course) { create(:course, organization: organization) }

    before do
      tee_sheet = create(:tee_sheet, course: course, date: Date.current)
      tee_time = create(:tee_time, tee_sheet: tee_sheet, starts_at: Time.current)
      create_list(:booking, 5, user: frequent, tee_time: tee_time)
      create(:booking, user: occasional, tee_time: tee_time)
    end

    it "filters with min bookings" do
      data = execute(minBookings: 3)
      ids = data.dig("data", "customers", "nodes").map { |n| n["id"] }
      expect(ids).to include(frequent.id.to_s)
      expect(ids).not_to include(occasional.id.to_s)
    end

    it "filters with max bookings" do
      data = execute(maxBookings: 2)
      ids = data.dig("data", "customers", "nodes").map { |n| n["id"] }
      expect(ids).not_to include(frequent.id.to_s)
      expect(ids).to include(occasional.id.to_s)
    end
  end

  describe "sorting" do
    let!(:alice) { create(:user, organization: organization, first_name: "Alice", last_name: "Abrams", created_at: 2.days.ago) }
    let!(:zara) { create(:user, organization: organization, first_name: "Zara", last_name: "Zito", created_at: 1.day.ago) }

    it "sorts by name ascending" do
      data = execute(sortBy: "name", sortDir: "asc")
      names = data.dig("data", "customers", "nodes").map { |n| n["fullName"] }
      expect(names.first).to eq("Alice Abrams")
    end

    it "sorts by created_at descending by default" do
      data = execute
      nodes = data.dig("data", "customers", "nodes")
      dates = nodes.map { |n| n["id"] }
      # Most recent should come first (manager was created most recently)
      expect(dates.first).to eq(manager.id.to_s).or eq(zara.id.to_s)
    end
  end

  describe "pagination" do
    before do
      create_list(:user, 10, organization: organization, role: :golfer)
    end

    it "paginates results" do
      data = execute(perPage: 5, page: 1)
      connection = data.dig("data", "customers")
      expect(connection["nodes"].length).to eq(5)
      expect(connection["page"]).to eq(1)
      expect(connection["perPage"]).to eq(5)
      expect(connection["totalPages"]).to be >= 2
      expect(connection["totalCount"]).to be >= 11 # 10 + manager
    end

    it "returns second page" do
      data = execute(perPage: 5, page: 2)
      connection = data.dig("data", "customers")
      expect(connection["nodes"].length).to eq(5)
      expect(connection["page"]).to eq(2)
    end

    it "returns empty nodes for out-of-range page" do
      data = execute(perPage: 5, page: 100)
      nodes = data.dig("data", "customers", "nodes")
      expect(nodes).to be_empty
    end
  end
end
