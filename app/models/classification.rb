class Classification < ActiveRecord::Base
  has_many :stones
  has_many :children, class_name: "Classification", foreign_key: :parent_id
  belongs_to :parent, class_name: "Classification", foreign_key: :parent_id
end
