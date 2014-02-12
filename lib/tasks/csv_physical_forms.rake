desc "physical forms csv"
task :physical_forms_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT 
        id,
        name,
        description
      FROM sample_forms
      ORDER BY id
    )
    TO '/tmp/csv/physical_forms.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY physical_forms
    FROM '/tmp/csv/physical_forms.csv'
    WITH CSV HEADER
  ")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM physical_forms
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('physical_forms_id_seq', #{max_next_id})
  ")
  
end