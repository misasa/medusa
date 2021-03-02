class AddBoxIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :box_id,   :integer
  end
end
