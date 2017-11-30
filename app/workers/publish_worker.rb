class PublishWorker
  include Sidekiq::Worker

  def perform(id)
    # Do something
    prop = RecordProperty.find_by_global_id(id)
    obj = prop.datum if prop
    if obj.respond_to?(:publish!)
      obj.publish!
    else
      obj.published = true
      obj.save
    end
  end
end
