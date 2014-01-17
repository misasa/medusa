FactoryGirl.define do
  factory :attaching do
    association :attachment_file, factory: :attachment_file
    association :attachable, factory: :place
    position 1
  end
end