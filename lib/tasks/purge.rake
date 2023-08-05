namespace :purge do
  desc "Purge openweather json entries that are not from today"
  task openweather_calls: :environment do
    today = DateTime.now
    entries_count = WeatherCall.where("created_at < ?", today - 1.day).count
    entries = WeatherCall.where("created_at < ?", today - 1.day).destroy_all
    puts "Weather calls are purged from #{entries_count} entries"
  end
end
