FactoryGirl.define do
  factory :global_qr do
    association :record_property, factory: :record_property
    file_name "ファイル名１"
    content_type "コンテンツタイプ１"
    file_size 12345
    file_updated_at DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
    identifier 1
  end
end