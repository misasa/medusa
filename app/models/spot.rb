class Spot < ActiveRecord::Base
  include HasRecordProperty

  belongs_to :attachment_file

  validates :attachment_file, existence: true
  validates :spot_x, presence: true
  validates :spot_y, presence: true

  before_validation :generate_name, if: "name.blank?"
  before_validation :generate_stroke_width, if: "stroke_width.blank?"
#  after_create :attachment_to_target

  def generate_name
    if target_uid.blank? 
      self.name = "untitled spot #{attachment_file.spots.size + 1}"
    else
      record_property = RecordProperty.find_by_global_id(target_uid)
      if record_property.blank? || record_property.datum.blank?
        self.name = "#{target_uid}"
      else
        self.name = "spot of #{record_property.datum.name}"
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

  def spot_x_from_center
    spot_xy_from_center[0] if spot_xy_from_center
  end

  def spot_y_from_center
    spot_xy_from_center[1] if spot_xy_from_center
  end

  def to_svg
    "<circle #{svg_attributes.map { |k, v| "#{k}=\"#{v}\"" }.join(" ") }/>"
  end

  def svg_attributes
    {
      cx: spot_x,
      cy: spot_y,
      r: [attachment_file.original_width, attachment_file.original_height].max * radius_in_percent / 100,
      fill: fill_color,
      #title: "spot of '#{name}'",
      title: title,
      "fill-opacity" => opacity,
      stroke: stroke_color,
      "stroke-width" => stroke_width,
      #"data-spot" => Rails.application.routes.url_helpers.spot_path(self, script_name: Rails.application.config.relative_url_root),
      "data-spot" => decorate.target_path,
      "data-target-uid" => target_uid
    }
  end

  def title
    t = "Spot of '#{name}'"
    t += " for #{target.class} '#{target.name}'" if target
    t
  end

  def ref_image_x
    attachment_file.length ? (spot_x / attachment_file.length * 100) : nil
  end

  def ref_image_y
    attachment_file.length ? (spot_y / attachment_file.length * 100) : nil
  end

  def target
    record_property = RecordProperty.find_by_global_id(target_uid)
    return if record_property.blank? || record_property.datum.blank?
    record_property.datum
  end

private

  def spot_center_xy
    [attachment_file.width.to_f / attachment_file.length / 2 * 100, attachment_file.height.to_f / attachment_file.length / 2 * 100]
  end

  def attachment_to_target
    return unless target.respond_to? :attachment_files
    target.attachment_files << attachment_file
  end

end
