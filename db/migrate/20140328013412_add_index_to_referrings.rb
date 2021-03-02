class AddIndexToReferrings < ActiveRecord::Migration[4.2]
  def change
    add_index :referrings, [:bib_id, :referable_id, :referable_type], unique: true
  end
end
