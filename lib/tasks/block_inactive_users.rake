# frozen_string_literal: true

namespace :users do
  desc 'Block inactive Users'
  task block_inactive: :environment do
    days = ENV['USER_BLOCK_INACTIVITY'].to_i || 30
    puts "A User is considered inactive if they have not logged in for #{days} days."
    inactive_users = User.where('users.status !=2 AND users.last_login < ?',
                                days.days.ago).or(User.where('users.status !=2 AND users.last_login IS NULL AND users.created_at < ?',
                                                             days.days.ago))
    inactive_users = inactive_users.includes(:role).where.not(roles: { name: 'Administrator' })
    if inactive_users.any?
      size = inactive_users.size
      inactive_users.each do |user|
        user.update(status: 2)
        user.notify_admins_blocked_users_inactivity
        puts "Blocked user: #{user.email}"
      rescue StandardError => e
        puts "Failed to block #{user.email}: #{e.message}"
      end
      puts "Blocked #{size} inactive users."
    else
      puts 'No inactive users to block.'
    end
  end
end
