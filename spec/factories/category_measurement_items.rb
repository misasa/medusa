FactoryGirl.define do
  factory :category_measurement_item do
    association :measurement_item, factory: :measurement_item
    association :measurement_category, factory: :measurement_category
    position 1
  end
end