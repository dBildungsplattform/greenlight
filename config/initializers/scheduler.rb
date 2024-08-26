require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '60s' do
    User.disable_inactive_users
end
