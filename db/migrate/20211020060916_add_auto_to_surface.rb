class AddAutoToSurface < ActiveRecord::Migration[6.1]
  def change
    add_column :surfaces, :auto, :boolean, default: true, null:false
  end
end
