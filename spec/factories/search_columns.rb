FactoryBot.define do
  factory :search_column do
    user_id { 0 }
    datum_type { "Specimen" }
    name { "name" }
    display_name { "display_name" }
    display_order { 1 }
    display_type { 0 }
  end
end
