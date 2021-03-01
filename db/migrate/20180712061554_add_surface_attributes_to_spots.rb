class AddSurfaceAttributesToSpots < ActiveRecord::Migration[4.2]
  def change
    change_table :spots do |t|
      t.references :surface, index: true, comment: "SurfaceID"
      t.float :world_x, comment: "ワールドX座標"
      t.float :world_y, comment: "ワールドY座標"
    end
  end
end
