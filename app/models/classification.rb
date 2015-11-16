class Classification < ActiveRecord::Base
  has_many :stones
  has_many :children, class_name: "Classification", foreign_key: :parent_id
  belongs_to :parent, class_name: "Classification", foreign_key: :parent_id

  validates :name, presence: true, length: {maximum: 255}
  validates :sesar_material, presence: true, length: {maximum: 255}

  before_save :generate_full_name
  after_save  :reflection_child_full_name

  def generate_full_name
    if parent
      self.full_name = parent.full_name + ":" + name
    else
      self.full_name = name
    end
  end
  
  def check_classification(sesar_material, sesar_classification)
    return true if sesar_classification.blank? 
    case sesar_material
    when "Biology", "Mineral", "Rock"
      classifications = YAML.load(File.read("#{Rails.root}/config/material_classification.yml"))["classification"]
      if classifications[sesar_material].include?(sesar_classification)
        true
      else
        errors.add(:sesar_classification, "Input is incorrect")
        false
      end
    else
      errors[:base] << "This sesar_material doesn't have sesar_classification"
      false
    end
  end

  def reflection_child_full_name
    children(force_reload: true).map { |child| child.save }
  end
end
