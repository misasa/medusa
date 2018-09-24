class CreateSurfaceLayers < ActiveRecord::Migration
  def change
    create_table :surface_layers do |t|
      t.references :surface, null: false, index: true, comment: "SurfaceID"
      t.string :name, null: false, comment: "レイヤ名"
      t.integer :opacity, null: false, default: 100, comment: "不透明度"
      t.integer :priority, null: false, comment: "優先順位"
      t.timestamps

      t.index %i(surface_id name), unique: true
    end
  end
end
