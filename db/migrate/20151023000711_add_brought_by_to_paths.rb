class AddBroughtByToPaths < ActiveRecord::Migration[4.2]
  def change
    add_column :paths, :brought_in_by_id,  :integer
    add_column :paths, :brought_out_by_id, :integer
  end
end
