FactoryBot.define do
  factory :surface do
    sequence(:name) { |n| "surface_#{n}" }
  end
end
