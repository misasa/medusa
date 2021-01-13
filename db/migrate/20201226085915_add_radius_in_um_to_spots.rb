class AddRadiusInUmToSpots < ActiveRecord::Migration
  def change
    add_column :spots, :radius_in_um, :float, comment: "半径 micro meter"
  end
end
