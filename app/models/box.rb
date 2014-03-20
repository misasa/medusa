class Box < ActiveRecord::Base
  include HasRecordProperty
  include HasViewSpot
  include OutputPdf
  include OutputCsv

  acts_as_taggable
  with_recursive

  has_many :users
  has_many :stones
  has_many :children, class_name: "Box", foreign_key: :parent_id
  has_many :attachings, as: :attachable
  has_many :attachment_files, through: :attachings
  has_many :referrings, as: :referable
  has_many :bibs, through: :referrings
  belongs_to :parent, class_name: "Box", foreign_key: :parent_id
  belongs_to :box_type

  validates :box_type, existence: true, allow_nil: true
  validates :parent_id, existence: true, allow_nil: true
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :parent_id }
  validate :parent_id_not_equal_id, if: ->(box) { box.parent_id }

  after_save :reset_path

  def analyses
    analyses = []
    stones.each do |stone| 
      (analyses = analyses + stone.analyses) unless stone.analyses.empty?
    end
    analyses
  end

  private

  def parent_id_not_equal_id
    if self.id == self.parent_id
      errors.add(:parent_id, " make loop.")
    end
  end

  def reset_path
    self.path = ""
    self.update_column(:path, "/#{self.ancestors.map(&:name).join('/')}") if self.parent
  end

end
