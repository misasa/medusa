class AddColumnToClassification < ActiveRecord::Migration[4.2]
  def change
    add_column :classifications, :sesar_material, :string
    add_column :classifications, :sesar_classification, :string
  end
end
