FactoryBot.define do
  factory :specimen_custom_attribute do
    sequence(:value) { |n| "value_#{n}" }
    association :specimen, factory: :specimen
    association :custom_attribute, factory: :custom_attribute
  end
end
