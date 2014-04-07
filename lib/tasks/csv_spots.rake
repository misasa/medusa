desc "spots csv"
task :spots_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT 
        id,
        ref_image_id as attachment_file_id,
        name,
        description,
        ref_image_x as spot_x,
        ref_image_y as spot_y,
        target_uid,
        radius_in_percent,
        stroke_color,
        stroke_width,
        fill_color,
        fill_opacity,
        with_cross,
        created_at,
        updated_at
      FROM point_on_images
      ORDER BY id
    )
    TO '/tmp/medusa_csv_files/spots.csv'
    (FORMAT 'csv', HEADER);
  ")
  
end