class UpdateDatumTypeColumnToRecordProperties < ActiveRecord::Migration
  def up
    execute "UPDATE record_properties SET datum_type = 'Specimen' WHERE datum_type = 'Stone'"
  end
  
  def down
    execute "UPDATE record_properties SET datum_type = 'Stone' WHERE datum_type = 'Specimen'"
  end
end
