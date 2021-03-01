class AddCheckedAtToPaths < ActiveRecord::Migration[4.2]
  def change
    add_column :paths, :checked_at, :timestamp, comment: "棚卸日時"
  end
end
