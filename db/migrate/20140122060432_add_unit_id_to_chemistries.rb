class AddUnitIdToChemistries < ActiveRecord::Migration[4.2]
  def change
    add_column :chemistries, :unit_id, :integer
  end
end
