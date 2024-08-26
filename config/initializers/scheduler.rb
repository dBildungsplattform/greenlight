require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.cron '0 * * * *' do
    User.disable_inactive_users
end
