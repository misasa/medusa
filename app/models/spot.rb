class Spot < ActiveRecord::Base
  include HasRecordProperty

  belongs_to :attachment_file, inverse_of: :spots
  belongs_to :surface
  belongs_to :target_property, class_name: 'RecordProperty', foreign_key: "target_uid", primary_key: "global_id"

  with_options if: -> (spot) { spot.attachment_file_id } do |opt|
    opt.validates :attachment_file, existence: true
    opt.validates :spot_x, presence: true
    opt.validates :spot_y, presence: true
  end
  with_options if: -> (spot) { spot.surface_id } do |opt|
    opt.validates :surface, existence: true
    opt.validates :world_x, presence: true
    opt.validates :world_y, presence: true
  end

  before_validation :generate_name, if: "name.blank?"
  before_validation :generate_stroke_width, if: "stroke_width.blank?"
  before_save :set_world_xy
  before_save :sync_radius
#  after_create :attachment_to_target

  scope :with_surfaces, -> (surfaces){
    where("surface_id IN (?) or attachment_file_id IN (?)", surfaces.map(&:id).uniq, surfaces.map(&:image_ids).flatten.uniq)
  }

  scope :with_surface, -> (surface){
    where("surface_id = ? or attachment_file_id IN (?)", surface.id, surface.image_ids)
  }

  scope :within_bounds, -> (bounds){
    where("world_x >= ? and world_x <= ? and world_y >= ? and world_y <= ?",bounds[0],bounds[2],bounds[3],bounds[1])
  }

  def surface
    Surface.find_by(id: surface_id) || attachment_file.surfaces[0]
  rescue
    nil
  end

  def generate_name
    if target_uid.blank?
      if attachment_file
        self.name = "untitled spot #{attachment_file.spots.size + 1}"
      else
        self.name = "untitled spot #{surface.spots.size + 1}"
      end
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
    self.stroke_width = 1.0
    self.stroke_width = attachment_file.percent2pixel(0.5) if attachment_file
  end

  def sync_radius
    return unless attachment_file_id
    if self.radius_in_percent_changed?
      self.radius_in_um = radius_um_from_percent
    elsif self.radius_in_um_changed?
      self.radius_in_percent = radius_percent_from_um
    end
  end

  def set_world_xy
    return unless attachment_file_id
    self.spot_x, self.spot_y = spot_xy_from_world if self.world_x_changed? || self.world_y_changed?
    self.world_x, self.world_y = spot_world_xy if self.spot_x_changed? || self.spot_y_changed?
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

  def to_pmlame(args = {})
    return unless attachment_file.try(:image?)
    analysis = get_analysis
    return unless analysis
    result = {
      element: "#{name} <spot #{global_id}>",
      surface_id: surface.try!(:global_id),
      image_id: attachment_file.try!(:global_id),
      image_path: attachment_file.data.try!(:url),
      x_image: spot_x_from_center,
      y_image: spot_y_from_center,
    }
    if world_x && world_y
      result.merge!(
        { x_vs: world_x,
          y_vs: world_y
        }
      )
    end
    if analysis
      result.merge!(
        analysis.to_pmlame
      )
    end
    result
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
    return unless attachment_file && attachment_file.affine_matrix
    return if attachment_file.affine_matrix.empty?
    worlds = attachment_file.pixel_pairs_on_world(pixels)
    worlds[0]
  end

  def spot_xy_from_world
    worlds = [[world_x, world_y]]
    return unless attachment_file && attachment_file.affine_matrix
    return if attachment_file.affine_matrix.empty?
    pixels = attachment_file.world_pairs_on_pixel(worlds)
    pixels[0]
  end

  def world_x
    super || (spot_world_xy[0] if spot_world_xy)
  end

  def world_y
    super || (spot_world_xy[1] if spot_world_xy)
  end

  def radius_um_from_percent
    return unless attachment_file && attachment_file.affine_matrix
    return if attachment_file.affine_matrix.blank?
    return if radius_in_percent.blank?
    attachment_file.length_in_um * radius_in_percent/100.0
  end

  def radius_percent_from_um
    return unless attachment_file && attachment_file.affine_matrix
    return if attachment_file.affine_matrix.empty?
    return if radius_in_um.blank?
    radius_in_um / attachment_file.length_in_um * 100.0
  end

  def to_svg
    "<g><title>#{title}</title><circle #{svg_attributes.map { |k, v| "#{k}=\"#{v}\"" }.join(" ") }/></g>"
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
