FactoryGirl.define do
  factory :table do
    association :bib, factory: :bib
    association :measurement_category, factory: :measurement_category
    description "table_description"
    with_average true
    with_place true
  end
end
