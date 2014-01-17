FactoryGirl.define do
  factory :spot do
    association :attachment_file, factory: :attachment_file
    name "画像上点１"
    description "説明１"
    spot_x 1
    spot_y 1
    target_uid "blue"
    radius_in_percent 1
    stroke_color "blue"
    stroke_width 1
    fill_color "blue"
    opacity 1
    with_cross false
  end
end