class Referring < ActiveRecord::Base
  belongs_to :bibs
  belongs_to :referable, polymorphic: true

  validates :bibs, existence: true
end
