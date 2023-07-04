namespace :purge do
  desc "Purge openweather json entries that are not from today"
  task openweather_calls: :environment do
    today = DateTime.now
    entries_count = OpenweatherCall.where("created_at < ?", today - 1.day).count
    entries = OpenweatherCall.where("created_at < ?", today - 1.day).destroy_all
    puts "Openweather calls purged #{entries_count} entries"
  end
end
