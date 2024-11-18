# frozen_string_literal: true

require_relative 'task_helpers'
require 'csv'

def validate_room(args)
  user = User.find_by(email: args[:owner], provider: 'greenlight')
  if !user
    err "User #{args[:owner]} not found!"
    err "Configuration for room #{args[:name]} belonging to user #{args[:owner]} is invalid"
    return false
  else
    info "Found user #{args[:owner]} with ID #{user.id}"
  end
  args.each do |k, v|
    if ![:name, :owner].include?(k)
      if !['true', 'false'].include?(v.downcase)
        err "#{k}: #{v} (should be true or false)"
        err "Configuration for room #{args[:name]} belonging to user #{args[:owner]} is invalid"
        return false
      end
      info "#{k}: #{v}"
    end
  end
  info "Configuration for room #{args[:name]} belonging to user #{args[:owner]} is valid"
  return true
end

def create_room(args)
  # Necessary to prevent the Greenlight defaults from overwriting our defaults
  args.with_defaults(glRequireAuthentication: 'false', moderatorapproval: 'false', glAnyoneCanStart: 'false', glAnyoneJoinAsModerator: 'false', muteOnStart: 'true', glViewerAccessCode: 'false', glModeratorAccessCode: 'false')
  user = User.find_by(email: args[:owner], provider: 'greenlight')
  if !user
    err "User #{args[:owner]} not found!"
    exit 1
  end
  room = Room.create(name: args[:name], user_id: user.id)
  info "Created room #{room.id}"
  args.each do |k, v|
    if ![:name, :owner, :moderatorapproval, :glViewerAccessCode, :glModeratorAccessCode].include?(k)
      RoomMeetingOption.find_by(room: room.id, meeting_option: MeetingOption.find_by(name: k)).update(value: v.downcase)
      info "Set #{k} to #{v.downcase}"
    elsif k == :moderatorapproval && v.downcase == 'true'
      RoomMeetingOption.find_by(room: room.id, meeting_option: MeetingOption.find_by(name: 'guestPolicy')).update(value: 'ASK_MODERATOR')
      info "Set #{k} to ASK_MODERATOR"
    elsif [:glViewerAccessCode, :glModeratorAccessCode].include?(k) && v.downcase == 'true'
      RoomMeetingOption.find_by(room: room.id, meeting_option: MeetingOption.find_by(name: k)).update(value: SecureRandom.alphanumeric(6).downcase)
      info "Set #{k} to generated code"
    end
  end
end

namespace :room do
  desc 'Create a room'
  task :create, %i[name owner glRequireAuthentication moderatorapproval glAnyoneCanStart glAnyoneJoinAsModerator muteOnStart glViewerAccessCode glModeratorAccessCode] => :environment do |_task, args|
    args.with_defaults(glRequireAuthentication: 'false', moderatorapproval: 'false', glAnyoneCanStart: 'false', glAnyoneJoinAsModerator: 'false', muteOnStart: 'true', glViewerAccessCode: 'false', glModeratorAccessCode: 'false')
    validate_room(args)
    create_room(args)
    
    exit 0
  end
  
  desc 'Create rooms from CSV'
  task :from_csv, %i[file dryrun] => :environment do |_task, args|
    args.with_defaults(dryrun: 'false')
    info "Validating whole CSV file first"
    rooms = []
    CSV.foreach(args[:file], headers: true) do |room|
      info "#{room['Raumname']}"
      argmap = {
        :name => 'raumname',
        :owner => 'besitzer',
        :glRequireAuthentication => 'nutzer_muessen_eingeloggt_sein',
        :moderatorapproval => 'moderation_muss_beitritt_zustimmen',
        :glAnyoneCanStart => 'jeder_kann_konferenz_starten',
        :glAnyoneJoinAsModerator => 'jeder_nimmt_als_moderation_teil',
        :muteOnStart => 'nutzer_anfangs_stummschalten',
        :glViewerAccessCode => 'zugangscode_fuer_zuhoerer_generieren',
        :glModeratorAccessCode => 'zugangscode_fuer_moderation_generieren'
      }
      roomargs = {}
      argmap.each do |gl, csv|
        if !room[csv] || room[csv].empty?
          info "Ignoring room[#{csv}] as it is empty"
        else
          if room[csv] == 'ja'
            info "Converting 'ja' to 'true'"
            room[csv] = 'true'
          elsif room[csv] == 'nein'
            info "Converting 'nein' to 'false'"
            room[csv] = 'false'
          end
          info "Setting roomargs[#{gl}] to room[#{csv}] (#{room[csv]})"
          roomargs[gl] = room[csv]
        end
      end
      if !validate_room(roomargs)
        exit 1
      end
      rooms << roomargs
    end
    
    unless args[:dryrun].downcase == 'false'
      info "Dry-run is active, stopping before creating any rooms"
      exit 0
    end
    
    info "Dry-run is not active, creating rooms"
    rooms.each do |roomargs|
      create_room(roomargs)
    end
    exit 0
  end
end
