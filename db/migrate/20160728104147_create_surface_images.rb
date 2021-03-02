class CreateSurfaceImages < ActiveRecord::Migration[4.2]
  def change
    create_table :surface_images do |t|
      t.integer :surface_id
      t.integer :image_id
      t.integer :position
      t.boolean :wall
      t.timestamps
    end
  end
end
