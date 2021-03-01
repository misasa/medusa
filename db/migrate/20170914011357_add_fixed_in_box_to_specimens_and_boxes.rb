class AddFixedInBoxToSpecimensAndBoxes < ActiveRecord::Migration[4.2]
  def change
    add_column :specimens, :fixed_in_box, :boolean, null: false, default: false, comment: "固定格納フラグ"
    add_column :boxes, :fixed_in_box, :boolean, null: false, default: false, comment: "固定格納フラグ"
  end
end
