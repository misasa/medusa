FactoryGirl.define do
  factory :measurement_category do
    sequence(:name) { |n| "measurement_category_#{n}" }
    description "説明１"
    association :unit, factory: :unit
  end
end
