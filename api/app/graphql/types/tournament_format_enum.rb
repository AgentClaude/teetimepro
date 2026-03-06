module Types
  class TournamentFormatEnum < Types::BaseEnum
    value "STROKE", "Stroke play — lowest total strokes wins", value: "stroke"
    value "MATCH_PLAY", "Match play — hole-by-hole competition", value: "match_play"
    value "SCRAMBLE", "Scramble — team picks best shot each stroke", value: "scramble"
    value "BEST_BALL", "Best ball — team uses lowest individual score per hole", value: "best_ball"
  end
end
