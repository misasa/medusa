class CreateCustomAttributes < ActiveRecord::Migration
  def change
    create_table :custom_attributes do |t|
      t.string :name
      t.string :sesar_name

      t.timestamps
    end
  end
end
