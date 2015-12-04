class AddSesarSampleTypeToPhysicalForms < ActiveRecord::Migration
  def change
    add_column :physical_forms, :sesar_sample_type, :string
  end
end
