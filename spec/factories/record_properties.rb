# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :record_property do
    association :datum, factory: :place
    association :user, factory: :user
    association :group, factory: :group
    owner_readable true
    owner_writable true
    group_readable true
    group_writable true
    guest_readable false
    guest_writable false
    global_id "グローバルID１"
    published false
    published_at DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
  end
end
