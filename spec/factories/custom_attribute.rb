FactoryBot.define do
  factory :custom_attribute do
    sequence(:name) { |n| "name_#{n}" }
    sequence(:sesar_name) { |n| "sesar_name_#{n}" }
  end
end
