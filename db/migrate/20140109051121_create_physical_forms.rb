class CreatePhysicalForms < ActiveRecord::Migration
  def change
    create_table :physical_forms do |t|
      t.string :name
      t.text   :description
    end
  end
end
