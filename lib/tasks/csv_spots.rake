desc "spots csv"
task :spots_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT
        poi.id,
        poi.ref_image_id as attachment_file_id,
        poi.name,
        poi.description,
        poi.ref_image_x / 100 * attachments.long as spot_x,
        poi.ref_image_y / 100 * attachments.long as spot_y,
        poi.target_uid,
        poi.radius_in_percent,
        poi.stroke_color,
        poi.stroke_width,
        poi.fill_color,
        poi.fill_opacity,
        poi.with_cross,
        poi.created_at,
        poi.updated_at
      FROM point_on_images poi
      INNER JOIN (
        SELECT
          id,
          CASE WHEN SPLIT_PART(original_geometry, 'x', 1) > SPLIT_PART(original_geometry, 'x', 2)
          THEN SPLIT_PART(original_geometry, 'x', 1)
          ELSE SPLIT_PART(original_geometry, 'x', 2)
          END::Integer as long
        FROM attachments
      ) attachments ON poi.ref_image_id = attachments.id
      ORDER BY poi.id
    )
    TO '/tmp/medusa_csv_files/spots.csv'
    (FORMAT 'csv', HEADER);
  ")
  
end