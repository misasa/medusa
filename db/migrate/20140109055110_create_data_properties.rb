class CreateDataProperties < ActiveRecord::Migration
  def change
    create_table :data_properties do |t|
      t.integer  :datum_id
      t.string   :datum_type
      t.integer  :user_id
      t.integer  :project_id
      t.integer  :u_permission
      t.integer  :p_permission
      t.integer  :o_permission
      t.string   :uniq_id
      t.boolean  :published, :default => false
      t.datetime :published_at
    end
    
    add_index :data_properties, :datum_id
    add_index :data_properties, :project_id
  end
end
