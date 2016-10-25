FactoryGirl.define do
  factory :specimen do
    name "ストーン１"
    specimen_type "サンプル１"
    description "説明１"
    parent_id ""
    association :place, factory: :place
    association :box, factory: :box
    association :physical_form, factory: :physical_form
    association :classification, factory: :classification
    quantity 100
    quantity_unit "kg"
    sequence(:igsn) { |n| "%09d" % "#{n}" }
    age_min 1
    age_max 10
    age_unit "a"
    size "111"
    size_unit "k"
    collector ""
    collector_detail ""
    collection_date_precision ""
  end
end
