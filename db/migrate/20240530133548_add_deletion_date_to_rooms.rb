class AddDeletionDateToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :deletion_date, :datetime
  end
end
