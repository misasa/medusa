class AddGlobeToSurfaces < ActiveRecord::Migration
  def change
    change_table :surfaces do |t|
      t.boolean :globe, null: false, default: false, comment: "地球表面フラグ"
    end
  end
end
