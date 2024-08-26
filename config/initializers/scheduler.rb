require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.cron '0 0 * * *' do
    User.block_inactive_users
    Room.delete_expired_rooms
end
