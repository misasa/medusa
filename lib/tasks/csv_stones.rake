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
    TO '/tmp/csv/stones.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.connection.execute("
    ALTER TABLE specimens
    DROP quantity,
    DROP quantity_unit
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY stones
    FROM '/tmp/csv/stones.csv'
    WITH CSV HEADER
  ")
  
  max_next_stone_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM stones
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('stones_id_seq', #{max_next_stone_id})
  ")
  
end