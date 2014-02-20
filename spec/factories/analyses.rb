FactoryGirl.define do
  factory :analysis do
    name "分析１"
    description "説明１"
    association :stone, factory: :stone
    association :technique, factory: :technique
    association :device, factory: :device
    operator "オペレータ１"
  end
end