class LeaderboardChannel < ApplicationCable::Channel
  def subscribed
    tournament = Tournament.find_by(id: params[:tournament_id])

    if tournament
      stream_from "leaderboard_#{tournament.id}"
    else
      reject
    end
  end
end
