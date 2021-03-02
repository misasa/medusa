class AddAttachmentDataToSurfaceImages < ActiveRecord::Migration[4.2]
  def self.up
    change_table :surface_images do |t|
      t.attachment :data
    end
  end

  def self.down
    drop_attached_file :surface_images, :data
  end
end
