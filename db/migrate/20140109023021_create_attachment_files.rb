class CreateAttachmentFiles < ActiveRecord::Migration
  def change
    create_table :attachment_files do |t|
      t.string   :name
      t.text     :description
      t.string   :md5hash
      t.string   :file_name
      t.string   :content_type
      t.integer  :file_size
      t.datetime :file_updated_at
      t.string   :original_geometry
      t.text     :affine_matrix
    end
  end
end
