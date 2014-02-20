FactoryGirl.define do
  factory :chemistry do
    association :analysis, factory: :analysis
    association :measurement_item, factory: :measurement_item
    info "インフォ１"
    value 1
    label "ラベル１"
    association :unit, factory: :unit
    description "説明１"
    uncertainty 1
  end
end