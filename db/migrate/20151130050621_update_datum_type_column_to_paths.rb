class UpdateDatumTypeColumnToPaths < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE paths SET datum_type = 'Specimen' WHERE datum_type = 'Stone'"
  end
  
  def down
    execute "UPDATE paths SET datum_type = 'Stone' WHERE datum_type = 'Specimen'"
  end
end
