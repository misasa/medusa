class StoneCustomAttribute < ActiveRecord::Base
  belongs_to :stone
  belongs_to :custom_attribute
end
