class AddDescriptionToBoxes < ActiveRecord::Migration[4.2]
  def change
    add_column :boxes, :description, :string
  end
end
