class SpecimenSurface < ActiveRecord::Base
  belongs_to :specimen
  belongs_to :surface
end
