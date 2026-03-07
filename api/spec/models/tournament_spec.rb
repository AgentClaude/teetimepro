require "rails_helper"

RSpec.describe Tournament, type: :model do
  subject(:tournament) { build(:tournament) }

  describe "associations" do
    it { is_expected.to belong_to(:course) }
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:created_by).class_name("User") }
    it { is_expected.to have_many(:tournament_entries).dependent(:destroy) }
    it { is_expected.to have_many(:participants).through(:tournament_entries) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_presence_of(:format) }

    it { is_expected.to validate_inclusion_of(:holes).in_array([9, 18]) }

    context "end_date before start_date" do
      it "is invalid" do
        tournament.end_date = tournament.start_date - 1.day
        expect(tournament).not_to be_valid
        expect(tournament.errors[:end_date]).to include("must be on or after start date")
      end
    end

    context "registration window" do
      it "is invalid when closes_at is before opens_at" do
        tournament.registration_opens_at = 1.week.from_now
        tournament.registration_closes_at = 1.day.from_now
        expect(tournament).not_to be_valid
        expect(tournament.errors[:registration_closes_at]).to include("must be after registration opens")
      end
    end

    context "team_size for individual formats" do
      it "requires team_size of 1 for stroke play" do
        tournament.format = :stroke
        tournament.team_size = 2
        expect(tournament).not_to be_valid
        expect(tournament.errors[:team_size]).to include("must be 1 for individual formats")
      end
    end

    context "team_size for team formats" do
      it "requires team_size >= 2 for scramble" do
        tournament.format = :scramble
        tournament.team_size = 1
        expect(tournament).not_to be_valid
        expect(tournament.errors[:team_size]).to include("must be at least 2 for team formats")
      end
    end

    context "max_participants < min_participants" do
      it "is invalid" do
        tournament.max_participants = 4
        tournament.min_participants = 10
        expect(tournament).not_to be_valid
        expect(tournament.errors[:max_participants]).to include("must be greater than or equal to minimum participants")
      end
    end
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:format).with_values(stroke: 0, match_play: 1, scramble: 2, best_ball: 3, stableford: 4) }
    it {
      is_expected.to define_enum_for(:status).with_values(
        draft: 0, registration_open: 1, registration_closed: 2,
        in_progress: 3, completed: 4, cancelled: 5
      )
    }
  end

  describe "scopes" do
    let(:org) { create(:organization) }
    let(:course) { create(:course, organization: org) }
    let(:user) { create(:user, organization: org, role: :manager) }

    describe ".for_organization" do
      it "returns only tournaments for the given org" do
        our_tournament = create(:tournament, organization: org, course: course, created_by: user)
        other_org = create(:organization)
        other_course = create(:course, organization: other_org)
        other_user = create(:user, organization: other_org, role: :manager)
        _other = create(:tournament, organization: other_org, course: other_course, created_by: other_user)

        expect(Tournament.for_organization(org)).to eq([our_tournament])
      end
    end

    describe ".upcoming" do
      it "returns future non-cancelled tournaments" do
        upcoming = create(:tournament, organization: org, course: course, created_by: user,
                          start_date: 1.week.from_now, end_date: 1.week.from_now)
        _past = create(:tournament, organization: org, course: course, created_by: user,
                       start_date: 1.week.ago, end_date: 1.week.ago)
        _cancelled = create(:tournament, organization: org, course: course, created_by: user,
                            start_date: 2.weeks.from_now, end_date: 2.weeks.from_now, status: :cancelled)

        expect(Tournament.upcoming).to eq([upcoming])
      end
    end
  end

  describe "#full?" do
    let(:tournament) { create(:tournament, :registration_open, min_participants: 2, max_participants: 2) }

    it "returns false when under capacity" do
      expect(tournament).not_to be_full
    end

    it "returns true when at capacity" do
      create_list(:tournament_entry, 2, tournament: tournament)
      expect(tournament).to be_full
    end

    it "ignores withdrawn entries" do
      create(:tournament_entry, tournament: tournament)
      create(:tournament_entry, :withdrawn, tournament: tournament)
      expect(tournament).not_to be_full
    end
  end

  describe "#registration_available?" do
    it "returns true when open and not full" do
      tournament = build(:tournament, :registration_open)
      expect(tournament.registration_available?).to be true
    end

    it "returns false when draft" do
      tournament = build(:tournament, status: :draft)
      expect(tournament.registration_available?).to be false
    end
  end

  describe "#team_format? / #individual_format?" do
    it "stroke is individual" do
      tournament = build(:tournament, format: :stroke)
      expect(tournament.individual_format?).to be true
      expect(tournament.team_format?).to be false
    end

    it "scramble is team" do
      tournament = build(:tournament, :scramble)
      expect(tournament.team_format?).to be true
      expect(tournament.individual_format?).to be false
    end
  end

  describe "#days" do
    it "calculates days correctly for single-day" do
      tournament = build(:tournament, start_date: Date.new(2026, 4, 1), end_date: Date.new(2026, 4, 1))
      expect(tournament.days).to eq(1)
    end

    it "calculates days correctly for multi-day" do
      tournament = build(:tournament, start_date: Date.new(2026, 4, 1), end_date: Date.new(2026, 4, 3))
      expect(tournament.days).to eq(3)
    end
  end
end
