FactoryGirl.define do
  factory :box do
    sequence(:name) { |n| "box_#{n}" }
    parent_id nil
    position 1
    path "/path"
    association :box_type, factory: :box_type
  end
end