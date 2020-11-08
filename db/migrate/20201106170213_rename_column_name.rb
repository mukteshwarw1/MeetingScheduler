class RenameColumnName < ActiveRecord::Migration[6.0]
  def change
  	rename_column :meetings, :meeting_tims, :meeting_time
  end
end
