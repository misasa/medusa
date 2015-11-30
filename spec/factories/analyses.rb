FactoryGirl.define do
  factory :analysis do
    name "分析１"
    description "説明１"
    association :specimen, factory: :specimen
    association :technique, factory: :technique
    association :device, factory: :device
    operator "オペレータ１"
  end
end
