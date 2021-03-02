class UpdateTaggableTypeColumnToTaggings < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE taggings SET taggable_type = 'Specimen' WHERE taggable_type = 'Stone'"
  end
  
  def down
    execute "UPDATE taggings SET taggable_type = 'Stone' WHERE taggable_type = 'Specimen'"
  end
end
