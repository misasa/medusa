desc "stones csv"
task :stones_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    ALTER TABLE specimens
    ADD quantity FLOAT,
    ADD quantity_unit VARCHAR
  ")
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT 
        id,
        name,
        specimen_type as stone_type,
        description,
        parent_id,
        locality_id as place_id,
        storage_id as box_id,
        form_id as physical_form_id,
        classification_id,
        quantity,
        quantity_unit,
        created_at,
        updated_at
      FROM specimens
      ORDER BY id
    )
    TO '/tmp/medusa_csv_files/stones.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    ALTER TABLE specimens
    DROP quantity,
    DROP quantity_unit
  ")
  
end