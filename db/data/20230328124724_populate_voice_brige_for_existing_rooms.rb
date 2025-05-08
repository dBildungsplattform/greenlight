# frozen_string_literal: true

class PopulateVoiceBrigeForExistingRooms < ActiveRecord::Migration[7.0]
  def up
    return if Rails.application.config.voice_bridge_phone_number.nil?

    raise 'The db contains to many rooms to assign each one a unique voice_bridge' if Room.all.length > 89_999

    Room.where(voice_bridge: nil).find_each do |room|
      id = SecureRandom.random_number(10.pow(5) - 1)

      id += 10_000 if id < 10_000

      while Room.exists?(voice_bridge: id)
        id += 1
        id = 10_000 if id >= 99_999
      end

      room.update(voice_bridge: id)
    end
  end

  def down
    Room.update_all(voice_bridge: nil)
  end
end
