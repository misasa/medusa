class CreateUniqQrs < ActiveRecord::Migration
  def change
    create_table :uniq_qrs do |t|
      t.integer  :data_property_id
      t.string   :file_name
      t.string   :content_type
      t.integer  :file_size
      t.datetime :file_updated_at
      t.string   :identifier
    end
    
    add_index :uniq_qrs, :data_property_id
  end
end
