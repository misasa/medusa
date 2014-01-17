FactoryGirl.define do
  factory :analysis do
    name "分析１"
    description "説明１"
    association :stone, factory: :stone
    technique "分析手法１"
    device "分析機器１"
    operator "オペレータ１"
  end
end