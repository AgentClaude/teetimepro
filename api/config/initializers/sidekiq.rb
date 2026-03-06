Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("SIDEKIQ_REDIS_URL", "redis://localhost:6379/1") }

  # Schedule recurring jobs
  config.on(:startup) do
    schedule = {
      "generate_daily_tee_sheets" => {
        "cron" => "0 2 * * *", # Every day at 2 AM
        "class" => "GenerateDailyTeeSheetJob",
        "description" => "Generate tee sheets for upcoming days"
      },
      "send_scheduled_campaigns" => {
        "cron" => "*/5 * * * *", # Every 5 minutes
        "class" => "SendScheduledCampaignsJob",
        "description" => "Send scheduled SMS campaigns that are due"
      },
      "morning_reminders" => {
        "cron" => "0 6 * * *", # Every day at 6 AM
        "class" => "SendReminderJob",
        "args" => ["morning_batch"],
        "description" => "Send morning-of tee time reminders"
      }
    }

    Sidekiq::Cron::Job.load_from_hash(schedule)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("SIDEKIQ_REDIS_URL", "redis://localhost:6379/1") }
end
