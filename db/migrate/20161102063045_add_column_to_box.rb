class AddColumnToBox < ActiveRecord::Migration[4.2]
  def change
    change_table :boxes do |t|
      t.float :quantity, comment: "数量"
      t.string :quantity_unit, comment: "数量単位"
    end
  end
end
