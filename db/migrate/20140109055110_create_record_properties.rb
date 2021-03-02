class CreateRecordProperties < ActiveRecord::Migration[4.2]
  def change
    create_table :record_properties do |t|
      t.integer  :datum_id
      t.string   :datum_type
      t.integer  :user_id
      t.integer  :group_id
      t.integer  :permission_u
      t.integer  :permission_g
      t.integer  :permission_o
      t.string   :global_id
      t.boolean  :published, :default => false
      t.datetime :published_at
    end
    
    add_index :record_properties, :datum_id
    add_index :record_properties, :user_id
    add_index :record_properties, :group_id
  end
end
