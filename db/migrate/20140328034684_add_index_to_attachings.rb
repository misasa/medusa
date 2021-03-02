class AddIndexToAttachings < ActiveRecord::Migration[4.2]
  def change
    add_index :attachings, [:attachment_file_id, :attachable_id, :attachable_type], unique: true, name: 'index_on_attachings_attachable_type_and_id_and_file_id'
  end
end
