FactoryGirl.define do
  factory :measurement_category do
    name "測定種類１"
    description "説明１"
    association :unit, factory: :unit
  end
end
