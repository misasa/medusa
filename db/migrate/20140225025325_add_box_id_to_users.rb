class AddBoxIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :box_id,   :integer
  end
end
