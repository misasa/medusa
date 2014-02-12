class RenameFileNameToAttachmentFiles < ActiveRecord::Migration
  def change
    rename_column :attachment_files, :file_name, :data_file_name
    rename_column :attachment_files, :file_size, :data_file_size
    rename_column :attachment_files, :content_type, :data_content_type
    rename_column :attachment_files, :file_updated_at, :data_updated_at
  end
end
