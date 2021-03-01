class AddRadiusInUmToSpots < ActiveRecord::Migration[4.2]
  def change
    add_column :spots, :radius_in_um, :float, comment: "半径 micro meter"
  end
end
