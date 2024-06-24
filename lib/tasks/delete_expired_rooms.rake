# frozen_string_literal: true

namespace :rooms do
  desc 'Delete rooms where deletion_date has passed'
  task delete_expired: :environment do
    expired_rooms = Room.where(deletion_date: ...Time.current)
    AutomatedDeletionOfExpiredRoomsId = Setting.find_by(name: 'AutomatedDeletionOfExpiredRooms')&.id
    is_automated_deletion_enabled = SiteSetting.find_by(setting_id: AutomatedDeletionOfExpiredRoomsId)&.value == 'true'

    if expired_rooms.any? && is_automated_deletion_enabled
      size = expired_rooms.size
      expired_rooms.each do |room|
        room.notify_room_deletion
        room.destroy
        puts "Deleted room #{room.id}"
      rescue StandardError => e
        puts "Failed to delete room #{room.id}: #{e.message}"
      end
      puts "Deleted #{size} expired rooms."
    else
      puts 'No expired rooms to delete, or automated deletion is disabled.'
    end
  end
end