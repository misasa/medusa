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
    TO '/tmp/csv/category_measurement_items.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY category_measurement_items
    FROM '/tmp/csv/category_measurement_items.csv'
    WITH CSV HEADER
  ")
  
  max_next_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM category_measurement_items
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('category_measurement_items_id_seq', #{max_next_id})
  ")
  
end