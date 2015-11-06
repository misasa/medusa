FactoryGirl.define do
  factory :table_analysis do
    association :table, factory: :table
    association :stone, factory: :stone
    association :analysis, factory: :analysis
    priority 1
  end
end
