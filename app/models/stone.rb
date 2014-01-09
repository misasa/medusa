class Stone < ActiveRecord::Base

  acts_as_taggable

  belongs_to :box
  belongs_to :classification
  belongs_to :physical_form

end
