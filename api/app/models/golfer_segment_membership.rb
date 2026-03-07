# frozen_string_literal: true

class GolferSegmentMembership < ApplicationRecord
  belongs_to :golfer_segment
  belongs_to :user

  validates :user_id, uniqueness: { scope: :golfer_segment_id }
end
