class CreateSpecimenSurfaces < ActiveRecord::Migration[4.2]
  def change
    create_table :specimen_surfaces do |t|
      t.references :specimen, index:true, foreign_key: true
      t.references :surface, index: true, foreign_key: true
      t.timestamps
    end
  end
end
