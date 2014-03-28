class AddIndexToReferrings < ActiveRecord::Migration
  def change
    add_index :referrings, [:bib_id, :referable_id, :referable_type], unique: true
  end
end
