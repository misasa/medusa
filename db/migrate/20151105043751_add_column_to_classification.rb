class AddColumnToClassification < ActiveRecord::Migration
  def change
    add_column :classifications, :sesar_material, :string
    add_column :classifications, :sesar_classification, :string
  end
end
