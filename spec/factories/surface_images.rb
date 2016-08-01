FactoryGirl.define do
  factory :surface_image do
    association :image, factory: :attachment_file
    association :surface, factory: :surface
    position 1
    wall nil
  end
end