class CreateSpots < ActiveRecord::Migration
  def change
    create_table :spots do |t|
      t.integer :attachment_file_id
      t.string  :name
      t.text    :description
      t.float   :spot_x
      t.float   :spot_y
      t.string  :target_uid
      t.float   :radius_in_percent
      t.string  :stroke_color
      t.float   :stroke_width
      t.string  :fill_color
      t.float   :opacity
      t.boolean :with_cross
      
      t.timestamps
    end
    
    add_index :spots, :attachment_file_id
  end
end
