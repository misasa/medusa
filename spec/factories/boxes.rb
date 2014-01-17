FactoryGirl.define do
  factory :box do
    name "保管場所１"
    parent_id ""
    position 1
    path "/パス１"
    association :box_type, factory: :box_type
  end
end