desc "places csv"
task :places_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT
        id,
        title as name,
        body as description,
        latitude,
        longitude,
        elevation,
        created_at,
        updated_at
      FROM localities
      ORDER BY id
    )
    TO '/tmp/csv/places.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY places
    FROM '/tmp/csv/places.csv'
    WITH CSV HEADER
  ")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM places
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('places_id_seq', #{max_next_id})
  ")
  
end