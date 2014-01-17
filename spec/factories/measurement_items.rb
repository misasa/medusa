FactoryGirl.define do
  factory :measurement_item do
    nickname "測定１"
    description "説明１"
    display_in_html "[A]"
    unit "parts"
    display_in_tex "\text{A}"
  end
end