class CreatePhysicalForms < ActiveRecord::Migration[4.2]
  def change
    create_table :physical_forms do |t|
      t.string :name
      t.text   :description
    end
  end
end
