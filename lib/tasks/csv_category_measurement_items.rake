desc "category measurement items csv"
task :category_measurement_items_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT 
        id,
        item_measured_id as measurement_item_id,
        item_type_id as measurement_category_id,
        display_order as position
      FROM itemtype_lists
      ORDER BY id
    )
    TO '/tmp/medusa_csv_files/category_measurement_items.csv'
    (FORMAT 'csv', HEADER);
  ")
  
end