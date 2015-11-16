FactoryGirl.define do
  factory :stone_custom_attribute do
    sequence(:value) { |n| "value_#{n}" }
    association :stone, factory: :stone
    association :custom_attribute, factory: :custom_attribute
  end
end
