namespace :rooms do
    desc "Delete rooms where deletion_date has passed"
    task delete_expired: :environment do
      expired_rooms = Room.where('deletion_date < ?', Time.current)
  
      if expired_rooms.any?
        size = expired_rooms.size
        expired_rooms.each do |room|
          begin
            room.notify_room_deletion
            room.destroy
            puts "Deleted room #{room.id}"   
          rescue => e
            puts "Failed to delete room #{room.id}: #{e.message}"      
          end
        end  
        puts "Deleted #{size} expired rooms."   
      else
        puts "No expired rooms to delete."    
      end
    end
  end
  