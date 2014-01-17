FactoryGirl.define do
  factory :attachment_file do
    name "添付ファイル１"
    description "説明１"
    md5hash "abcde"
    file_name "ファイル名１"
    content_type "コンテンツタイプ１"
    file_size 12345
    file_updated_at DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
    original_geometry "123x123"
    affine_matrix "affine_matrix１"
  end
end