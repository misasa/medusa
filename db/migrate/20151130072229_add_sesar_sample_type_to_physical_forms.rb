class AddSesarSampleTypeToPhysicalForms < ActiveRecord::Migration[4.2]
  def change
    add_column :physical_forms, :sesar_sample_type, :string
  end
end
