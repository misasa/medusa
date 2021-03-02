FactoryBot.define do
  factory :table_analysis do
    association :table, factory: :table
    association :specimen, factory: :specimen
    association :analysis, factory: :analysis
    priority { 1 }
  end
end
