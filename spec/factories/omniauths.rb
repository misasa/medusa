FactoryGirl.define do
  factory :omniauth do
    provider "sample_provider"
    uid "1234567890"
    association :user, factory: :user
  end
end
