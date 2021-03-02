FactoryBot.define do
  factory :table_specimen do
    association :table, factory: :table
    association :specimen, factory: :specimen
    position { 1 }
  end
end
