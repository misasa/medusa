class Box < ActiveRecord::Base
  include HasRecordProperty

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

  private

  def parent_id_not_equal_id
    if self.id == self.parent_id
      errors.add(:parent_id, " make loop.")
    end
  end
end
