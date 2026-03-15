require "rails_helper"

RSpec.describe CourseHole, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:course) }
  end

  describe "validations" do
    subject { build(:course_hole) }

    it { is_expected.to validate_presence_of(:hole_number) }
    it { is_expected.to validate_presence_of(:par) }
    it { is_expected.to validate_inclusion_of(:hole_number).in_range(1..36) }
    it { is_expected.to validate_inclusion_of(:par).in_range(3..6) }
  end

  describe "uniqueness" do
    let(:course) { create(:course) }

    it "prevents duplicate hole numbers per course" do
      create(:course_hole, course: course, hole_number: 1, par: 4)
      duplicate = build(:course_hole, course: course, hole_number: 1, par: 4)
      expect(duplicate).not_to be_valid
    end
  end

  describe "scopes" do
    let(:course) { create(:course) }

    before do
      (1..18).each { |n| create(:course_hole, course: course, hole_number: n, par: n <= 9 ? 4 : 5) }
    end

    it ".ordered returns holes in order" do
      holes = course.course_holes.ordered
      expect(holes.map(&:hole_number)).to eq((1..18).to_a)
    end

    it ".front_nine returns holes 1-9" do
      expect(course.course_holes.front_nine.count).to eq(9)
    end

    it ".back_nine returns holes 10-18" do
      expect(course.course_holes.back_nine.count).to eq(9)
    end
  end
end
