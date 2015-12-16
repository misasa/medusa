class AddCheckedAtToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :checked_at, :timestamp, comment: "棚卸日時"
  end
end
