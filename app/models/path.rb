class Path < ActiveRecord::Base

  include Enumerable

  belongs_to :datum, polymorphic: true

  scope :contents_of, -> (box_id) { where("? = ANY(ids)", box_id) }
  scope :current, -> { where(brought_out_at: nil) }

  def each
    if ids.present?
      boxes = Box.find(ids).index_by(&:id)
      ids.each { |id| yield boxes[id] }
    end
    yield datum
  end

end
