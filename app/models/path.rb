class Path < ActiveRecord::Base

  include Enumerable

  belongs_to :datum, polymorphic: true
  belongs_to :brought_in_by, foreign_key: :brought_in_by_id, class_name: "User"
  belongs_to :brought_out_by, foreign_key: :brought_out_by_id, class_name: "User"

  scope :contents_of, -> (box_id) { where("? = ANY(ids)", box_id) }
  scope :current, -> { where(brought_out_at: nil) }
  scope :exists_at, -> (date) { where(arel_table[:brought_in_at].lteq(date.to_date.end_of_day).and(arel_table[:brought_out_at].eq(nil).or(arel_table[:brought_out_at].gteq(date.to_date.beginning_of_day)))) rescue none }

  def self.cont_at(date)
    search = search(brought_out_at_gteq: date, brought_in_at_lteq_end_of_day: date)
    records = search.result
    records = records.current if search.conditions.empty?
    records = records.group(:datum_id, :datum_type, :ids)
    records = records.select(:datum_id, :datum_type, :ids, arel_table[:brought_in_at].maximum.as("brought_in_at"), arel_table[:brought_out_at].maximum.as("brought_out_at"), arel_table[:checked_at].maximum.as("checked_at"))
    records
  end

  def self.snapshot(box, date)
    #params[:q][:exists_at] = @dst_date
    #@contents_search = Path.contents_of(@box).search(params[:q])
    records = contents_of(box)
    records = records.search({exists_at: date}).result
    records
  end

  def self.integ(box, src_date, dst_date)
    paths = arel_table
    records = contents_of(box)
    records = records.select("CASE WHEN brought_in_at < '#{src_date}' AND brought_out_at > '#{dst_date}' THEN '' WHEN brought_out_at IS NOT NULL AND brought_out_at < '#{dst_date}' THEN '-' ELSE '+' END AS sign, datum_id, datum_type, ids, brought_in_at, brought_out_at, checked_at")
    #params[:q][:brought_out_at_gteq] = sdate.strftime("%Y-%m-%d")
    #params[:q][:brought_in_at_lteq_end_of_day] = @dst_date
    records = records.search({brought_out_at_gteq: src_date, brought_in_at_lteq_end_of_day: dst_date}).result
    records
  end

  def self.diff(box, src_date, dst_date)
    src = contents_of(box).cont_at(src_date).as("src")
    dst = contents_of(box).cont_at(dst_date).as("dst")
    join = arel_table.project("CASE WHEN src.datum_id IS NULL THEN '+' ELSE '-' END AS sign, COALESCE(src.datum_id, dst.datum_id) AS datum_id, COALESCE(src.datum_type, dst.datum_type) AS datum_type, COALESCE(src.ids, dst.ids) AS ids, COALESCE(src.brought_in_at, dst.brought_in_at) AS brought_in_at, COALESCE(src.brought_out_at, dst.brought_out_at) AS brought_out_at, COALESCE(src.checked_at, dst.checked_at) AS checked_at")
    join = join.from(src).join(dst, Arel::Nodes::FullOuterJoin).on(src[:datum_id].eq(dst[:datum_id]).and(src[:datum_type].eq(dst[:datum_type])).and(src[:ids].eq(dst[:ids])))
    join = join.where(src[:datum_id].eq(nil).or(dst[:datum_id].eq(nil)))
    select("*").from(join.as("paths"))
  end

  def self.change(box, src_date, dst_date)
    paths = arel_table
    records = contents_of(box)
    records = records.select("CASE WHEN brought_out_at IS NOT NULL THEN '-' ELSE '+' END AS sign, datum_id, datum_type, ids, brought_in_at, brought_out_at, checked_at")
    records = records.where(paths[:brought_in_at].gteq(src_date).and(paths[:brought_in_at].lteq(dst_date)).or(paths[:brought_out_at].gteq(src_date).and(paths[:brought_out_at].lteq(dst_date))))
    records
  end

  def each
    if ids.present?
      boxes = Box.where(id: ids).includes(:record_property).index_by(&:id)
      ids.each { |id| yield boxes[id] }
    end
    yield datum
  end

  def to_posix_style
    map(&:name).join("/")
  end

  def boxes
    if ids.present?
      boxes = Box.where(id: ids).includes(:record_property).index_by(&:id)
      ids.map {|id| boxes[id] }
    else
      []
    end

  end

  def self.ransackable_scopes(auth_object = nil)
    %i(exists_at)
  end

  private

  ransacker :path do
    Arel.sql("(SELECT string_agg(name, '/') FROM unnest(ids) AS i INNER JOIN boxes ON id = i) || '/' || (CASE datum_type WHEN 'Specimen' THEN (SELECT name FROM specimens WHERE id = datum_id) WHEN 'Box' THEN (SELECT name FROM boxes WHERE id = datum_id) END)")
  end

  ransacker :brought_out_at do |parent|
    Arel.sql("coalesce(brought_out_at, '9999-12-31 23:59:59')")
  end

  ransacker :brought_at do |parent|
    Arel.sql("coalesce(brought_out_at, brought_in_at)")
  end

  ransacker :sign do |parent|
    Arel.sql("CASE WHEN brought_out_at IS NULL THEN 1 ELSE 2 END")
  end

end
