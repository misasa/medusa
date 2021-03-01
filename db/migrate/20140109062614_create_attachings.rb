class CreateAttachings < ActiveRecord::Migration[4.2]
  def change
    create_table :attachings do |t|
      t.integer :attachment_file_id
      t.integer :attachable_id
      t.string  :attachable_type
      t.integer :position
      
      t.timestamps
    end
    
    add_index :attachings, :attachment_file_id
    add_index :attachings, :attachable_id
  end
end
