class AddBroughtByToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :brought_in_by_id,  :integer
    add_column :paths, :brought_out_by_id, :integer
  end
end
