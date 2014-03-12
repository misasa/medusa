FactoryGirl.define do
  factory :attachment_file do
    name "添付ファイル１"
    description "説明１"
    md5hash "abcde"
    data_file_name "file_name_1.jpg"
    data_content_type "image/jpg"
    data_file_size 12345
    data_updated_at DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
    original_geometry "123x123"
    affine_matrix [1,0,0,0,1,0,0,0,1]
  end
end
