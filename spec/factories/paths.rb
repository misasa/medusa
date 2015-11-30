FactoryGirl.define do
  factory :path_box, class: Path do
    datum_type "Box"
    brought_out_at "20151117"
    brought_in_at "20151116"
  end
  factory :path_specimen, class: Path do
    datum_type "Specimen"
    brought_out_at "20151117"
    brought_in_at "20151116"
  end
end
