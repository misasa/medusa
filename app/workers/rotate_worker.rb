class RotateWorker
  include Sidekiq::Worker

  def perform(image_id)
    # Do something
    image = AttachmentFile.find(image_id)
    temp_path = image.rotate
    File.delete(temp_path)
  end
end
