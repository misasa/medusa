FactoryGirl.define do
  factory :user do
    email "email@test.co.jp"
    username "user"
    password "password"
    password_confirmation "password"
    administrator true
    family_name "test"
    first_name "test"
    description "説明"
  end

  factory :user_foo, parent: :user do
    email "foo@example.com"
    username "foo"
  end

  factory :user_baa, parent: :user do
    email "baa@example.com"
    username "baa"
  end
end
