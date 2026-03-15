FactoryBot.define do
  factory :course_hole do
    course
    sequence(:hole_number) { |n| ((n - 1) % 18) + 1 }
    par { [3, 4, 4, 4, 5].sample }
    yardage { par == 3 ? rand(130..220) : par == 4 ? rand(300..450) : rand(480..580) }
    handicap_index { hole_number }
  end
end
