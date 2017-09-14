class RotateWorker
  include Sidekiq::Worker

  def perform(image_id)
    # Do something
    image = AttachmentFile.find(image_id)
    image.rotate
  end
end
