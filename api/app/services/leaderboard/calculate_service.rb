module Leaderboard
  class CalculateService < ApplicationService
    attr_accessor :tournament, :round_number

    validates :tournament, presence: true

    def call
      return validation_failure(self) unless valid?

      entries = tournament.tournament_entries.active.includes(:user, :tournament_scores)
      rounds = tournament.tournament_rounds.chronological.includes(:tournament_scores)

      leaderboard_entries = entries.map do |entry|
        build_leaderboard_entry(entry, rounds)
      end

      sorted = sort_entries(leaderboard_entries)
      ranked = assign_positions(sorted)

      success(
        entries: ranked,
        tournament_id: tournament.id,
        total_rounds: rounds.size,
        current_round: rounds.find(&:in_progress?)&.round_number
      )
    end

    private

    def build_leaderboard_entry(entry, rounds)
      round_scores = rounds.map do |round|
        scores = round.tournament_scores.select { |s| s.tournament_entry_id == entry.id }
        next nil if scores.empty?

        {
          round_number: round.round_number,
          total_strokes: scores.sum(&:strokes),
          total_par: scores.sum(&:par),
          score_to_par: scores.sum(&:score_to_par),
          holes_played: scores.size,
          completed: scores.size == tournament.holes
        }
      end.compact

      total_strokes = round_scores.sum { |r| r[:total_strokes] }
      total_par = round_scores.sum { |r| r[:total_par] }
      total_to_par = round_scores.sum { |r| r[:score_to_par] }
      total_holes = round_scores.sum { |r| r[:holes_played] }
      thru = current_round_thru(entry, rounds)

      {
        entry_id: entry.id,
        player_id: entry.user_id,
        player_name: entry.user.full_name,
        handicap_index: entry.handicap_index,
        team_name: entry.team_name,
        total_strokes: total_strokes,
        total_to_par: total_to_par,
        total_par: total_par,
        total_holes_played: total_holes,
        thru: thru,
        rounds: round_scores,
        position: nil, # assigned later
        tied: false
      }
    end

    def current_round_thru(entry, rounds)
      current = rounds.find(&:in_progress?)
      return nil unless current

      scores = current.tournament_scores.select { |s| s.tournament_entry_id == entry.id }
      return nil if scores.empty?

      scores.size >= tournament.holes ? "F" : scores.size.to_s
    end

    def sort_entries(entries)
      entries.sort_by do |e|
        if tournament.stableford?
          [-stableford_points(e), e[:total_strokes]]
        else
          [e[:total_to_par], e[:total_strokes]]
        end
      end
    end

    def stableford_points(entry)
      entry[:rounds].sum do |round_data|
        # Simplified: actual stableford calc would use handicap-adjusted scores
        round_data[:score_to_par] * -1 + 2 * round_data[:holes_played]
      end
    end

    def assign_positions(sorted)
      return sorted if sorted.empty?

      position = 1
      sorted.each_with_index do |entry, idx|
        if idx == 0
          entry[:position] = position
        else
          prev = sorted[idx - 1]
          if same_score?(entry, prev)
            entry[:position] = prev[:position]
            entry[:tied] = true
            prev[:tied] = true
          else
            position = idx + 1
            entry[:position] = position
          end
        end
      end

      sorted
    end

    def same_score?(a, b)
      if tournament.stableford?
        stableford_points(a) == stableford_points(b)
      else
        a[:total_to_par] == b[:total_to_par]
      end
    end
  end
end
