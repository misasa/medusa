class CreateSpecimenQuantities < ActiveRecord::Migration[4.2]
  def change
    create_table :specimen_quantities do |t|
      t.integer :specimen_id, comment: "標本ID"
      t.integer :divide_id, commit: "分取ID"
      t.float :quantity, comment: "数量"
      t.string :quantity_unit, comment: "数量単位"
      t.timestamps
    end

    change_table_comment(:specimen_quantities, "試料量")

    add_index :specimen_quantities, :specimen_id
    add_index :specimen_quantities, :divide_id
  end
end
