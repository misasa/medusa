class Spot < ActiveRecord::Base
  include HasRecordProperty

  belongs_to :attachment_file

  validates :attachment_file, existence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :spot_x, presence: true
  validates :spot_y, presence: true

  before_validation :generate_name, if: "name.blank?"
  before_validation :generate_stroke_width, if: "stroke_width.blank?"

  def generate_name
    if target_uid.blank? 
      self.name = "untitled point #{attachment_file.spots.size + 1}"
    else
      record_property = RecordProperty.find_by_global_id(target_uid)
      if record_property.blank? || record_property.datum.blank?
        self.name = target_uid
      else
        self.name = record_property.datum.name
      end
    end
  end

  def generate_stroke_width
    self.stroke_width = attachment_file.percent2pixel(1)
  end

  def spot_xy_from_center
    return unless attachment_file
    return unless spot_x
    return unless spot_y

    cpt = spot_center_xy
    [spot_x - cpt[0], cpt[1] - spot_y]
  end

  def to_svg
    "<circle #{svg_attributes.map { |k, v| "#{k}=\"#{v}\"" }.join(" ") }/>"
  end

  def svg_attributes
    {
      cx: spot_x,
      cy: spot_y,
      r: radius_in_percent,
      fill: fill_color,
      "fill-opacity" => opacity,
      stroke: stroke_color,
      "stroke-width" => stroke_width,
      "data-spot" => Rails.application.routes.url_helpers.edit_spot_path(self)
    }
  end

private

  def spot_center_xy
    return unless attachment_file
    [attachment_file.width.to_f / attachment_file.length / 2 * 100, attachment_file.height.to_f / attachment_file.length / 2 * 100]
  end

end
