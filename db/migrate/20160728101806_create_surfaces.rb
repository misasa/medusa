class CreateSurfaces < ActiveRecord::Migration[4.2]
  def change
    create_table :surfaces do |t|
      t.string :name

      t.timestamps
    end
  end
end
