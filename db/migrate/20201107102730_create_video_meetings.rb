class CreateVideoMeetings < ActiveRecord::Migration[6.0]
  def change
    create_table :video_meetings do |t|
      t.belongs_to :meeting, index: { unique: true }, foreign_key: true
      t.string :link_url
      t.integer :password
      t.string :status

      t.timestamps
    end
  end
end
