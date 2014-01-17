FactoryGirl.define do
  factory :referring do
    association :bib, factory: :bib
    association :referable, factory: :place
  end
end