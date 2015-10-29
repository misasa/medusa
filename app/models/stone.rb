class Stone < ActiveRecord::Base
  include HasRecordProperty
  include HasViewSpot
  include OutputPdf
  include OutputCsv
  include HasAttachmentFile
  include HasRecursive

  acts_as_taggable
 #with_recursive

  has_many :analyses
  has_many :children, class_name: "Stone", foreign_key: :parent_id, dependent: :nullify
  has_many :stones, class_name: "Stone", foreign_key: :parent_id, dependent: :nullify  
  has_many :referrings, as: :referable, dependent: :destroy
  has_many :bibs, through: :referrings
  has_many :chemistries, through: :analyses
  belongs_to :parent, class_name: "Stone", foreign_key: :parent_id
  belongs_to :box
  belongs_to :place
  belongs_to :classification
  belongs_to :physical_form

  validates :box, existence: true, allow_nil: true
  validates :place, existence: true, allow_nil: true
  validates :classification, existence: true, allow_nil: true
  validates :physical_form, existence: true, allow_nil: true
  validates :name, presence: true, length: { maximum: 255 }
  validate :parent_id_cannot_self_children, if: ->(stone) { stone.parent_id }


  # def to_pml
  #   [self].to_pml
  # end

  private

  def parent_id_cannot_self_children
    invalid_ids = descendants.map(&:id).unshift(self.id)
    if invalid_ids.include?(self.parent_id)
      errors.add(:parent_id, " make loop.")
    end
  end

end
