class AddCreatedAtUpdatedAtToAttachmentFiles < ActiveRecord::Migration
  def change
    add_column :attachment_files, :created_at, :datetime
    add_column :attachment_files, :updated_at, :datetime
  end
end
