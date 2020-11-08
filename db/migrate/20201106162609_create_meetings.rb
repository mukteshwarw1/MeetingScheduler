class CreateMeetings < ActiveRecord::Migration[6.0]
  def change
    create_table :meetings do |t|
      t.date :meeting_date
      t.time :meeting_tims
      t.string :meeting_type
      t.integer :participant
      t.integer :creator

      t.timestamps
    end
  end
end
