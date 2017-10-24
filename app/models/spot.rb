class Spot < ActiveRecord::Base
  include HasRecordProperty

  PMLAME_HEADER = %w(image_id image_path x_image y_image)

#  attr_accessor :spot_x_world, :spot_y_world
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
    self.stroke_width = attachment_file.percent2pixel(0.5)
  end


  def get_analysis
    target if target && target.instance_of?(Analysis)
  end

  def to_pml(xml=nil)
    unless xml
      xml = ::Builder::XmlMarkup.new(indent: 2)
      xml.instruct!
    end
    xml.acquisition do
      analysis = get_analysis
      if analysis
        xml.global_id(analysis.global_id)
        xml.name(analysis.name)
        xml.device(analysis.device.try!(:name))
        xml.technique(analysis.technique.try!(:name))
        xml.operator(analysis.operator)
        xml.sample_global_id(analysis.specimen.try!(:global_id))
        xml.sample_name(analysis.specimen.try!(:name))
        xml.description(analysis.description)
      end
      # spot = get_spot
      xml.spot do
        xml.global_id(global_id)
        xml.attachment_file_global_id(attachment_file.try!(:global_id))
        xml.attachment_file_path(attachment_file.data.try!(:url))
        xml.x_image(spot_x_from_center)
        xml.y_image(spot_y_from_center)
        xml.x_overpic(spot_overpic_x)
        xml.y_overpic(spot_overpic_y)
        world_xy = spot_world_xy
        if world_xy
          xml.x_vs(world_xy[0])
          xml.y_vs(world_xy[1])
        end
      end
      if analysis
        unless analysis.chemistries.empty?
          xml.chemistries do
            analysis.chemistries.each do |chemistry|
              xml.analysis do
                xml.nickname(chemistry.measurement_item.try!(:nickname))
                xml.value(chemistry.value)
                xml.unit(chemistry.unit.try!(:text))
                xml.uncertainty(chemistry.uncertainty)
                xml.label(chemistry.label)
                xml.info(chemistry.info)
              end
            end
          end
        end
      end
    end

  end

  def to_pmlame
    world_xy = spot_world_xy || []
    [
      attachment_file.try!(:global_id),
      attachment_file.data.try!(:url),
      spot_x_from_center,
      spot_y_from_center,
    ]
  end


  def spot_xy_from_center
    return unless attachment_file
    return unless spot_x
    return unless spot_y

    cpt = spot_center_xy
    [spot_x/attachment_file.length * 100 - cpt[0], cpt[1] - spot_y/attachment_file.length * 100]
  end

  def spot_x_from_center
    spot_xy_from_center[0] if spot_xy_from_center
  end

  def spot_y_from_center
    spot_xy_from_center[1] if spot_xy_from_center
  end

  def spot_overpic_x
    spot_x/attachment_file.length * 100 if attachment_file.length
  end

  def spot_overpic_y
    (attachment_file.height.to_f/attachment_file.length - spot_y/attachment_file.length) * 100 if attachment_file.length
  end

  def spot_world_xy
    pixels = [[spot_x, spot_y]]
    return unless attachment_file.affine_matrix
    return if attachment_file.affine_matrix.empty?
    worlds = attachment_file.pixel_pairs_on_world(pixels)
    worlds[0]
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
