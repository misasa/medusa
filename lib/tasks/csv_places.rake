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
    TO '/tmp/medusa_csv_files/places.csv'
    (FORMAT 'csv', HEADER);
  ")
  
end