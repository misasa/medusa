class Path < ActiveRecord::Base

  include Enumerable

  belongs_to :datum, polymorphic: true

  scope :contents_of, -> (box_id) { where("? = ANY(ids)", box_id) }
  scope :current, -> { where(brought_out_at: nil) }

  def each
    if ids.present?
      boxes = Box.where(id: ids).includes(:record_property).index_by(&:id)
      ids.each { |id| yield boxes[id] }
    end
    yield datum
  end

  private

  ransacker :path do
    Arel.sql("(SELECT string_agg(name, '/') FROM unnest(ids) AS i INNER JOIN boxes ON id = i) || '/' || (CASE datum_type WHEN 'Stone' THEN (SELECT name FROM stones WHERE id = datum_id) WHEN 'Box' THEN (SELECT name FROM boxes WHERE id = datum_id) END)")
  end

  ransacker :brought_out_at do |parent|
    Arel.sql("coalesce(brought_out_at, '9999-12-31 23:59:59')")
  end

end
