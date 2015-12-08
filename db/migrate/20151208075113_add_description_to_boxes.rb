class AddDescriptionToBoxes < ActiveRecord::Migration
  def change
    add_column :boxes, :description, :string
  end
end
