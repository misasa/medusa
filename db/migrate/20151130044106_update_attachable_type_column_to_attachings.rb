class UpdateAttachableTypeColumnToAttachings < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE attachings SET attachable_type = 'Specimen' WHERE attachable_type = 'Stone'"
  end
  
  def down
    execute "UPDATE attachings SET attachable_type = 'Stone' WHERE attachable_type = 'Specimen'"
  end
end
