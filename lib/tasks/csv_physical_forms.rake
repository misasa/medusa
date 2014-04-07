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
    TO '/tmp/medusa_csv_files/physical_forms.csv'
    (FORMAT 'csv', HEADER);
  ")
  
end