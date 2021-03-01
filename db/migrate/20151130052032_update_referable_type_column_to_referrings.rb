class UpdateReferableTypeColumnToReferrings < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE referrings SET referable_type = 'Specimen' WHERE referable_type = 'Stone'"
  end
  
  def down
    execute "UPDATE referrings SET referable_type = 'Stone' WHERE referable_type = 'Specimen'"
  end
end
