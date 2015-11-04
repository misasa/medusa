FactoryGirl.define do
  factory :table_stone do
    association :table, factory: :table
    association :stone, factory: :stone
    position 1
  end
end
