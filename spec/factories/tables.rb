FactoryGirl.define do
  factory :table do
    association :bib, factory: :bib
    association :measurement_category, factory: :measurement_category
    description "table_description"
    with_average true
    with_place true
    with_age true
    age_unit "a"
  end
end
