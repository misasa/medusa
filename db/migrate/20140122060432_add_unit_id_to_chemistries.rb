class AddUnitIdToChemistries < ActiveRecord::Migration
  def change
    add_column :chemistries, :unit_id, :integer
  end
end
