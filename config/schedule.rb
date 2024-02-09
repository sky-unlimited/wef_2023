# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# To update the crontab file:
# whenever --update-crontab --set 'environment=staging'

set :output, "/home/deploy/logs/wef_2023/cron.log"

every 1.day, at: ['6:00 am', '6:00 pm'], roles: [:app] do
  rake "weather:update"
end

