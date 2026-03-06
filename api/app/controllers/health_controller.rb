class HealthController < ActionController::API
  def show
    checks = {
      status: "ok",
      timestamp: Time.current.iso8601,
      database: database_check,
      redis: redis_check
    }

    status = checks.values_at(:database, :redis).all? { |c| c == "ok" } ? :ok : :service_unavailable
    render json: checks, status: status
  end

  private

  def database_check
    ActiveRecord::Base.connection.execute("SELECT 1")
    "ok"
  rescue StandardError
    "error"
  end

  def redis_check
    Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")).ping
    "ok"
  rescue StandardError
    "error"
  end
end
