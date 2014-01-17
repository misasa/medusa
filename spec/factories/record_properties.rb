FactoryGirl.define do
  factory :record_property do
    association :datum, factory: :place
    association :user, factory: :user
    association :group, factory: :group
    permission_u 6
    permission_g 6
    permission_o 0
    global_id "グローバルID１"
    published false
    published_at DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
  end
end