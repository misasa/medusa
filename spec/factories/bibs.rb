FactoryGirl.define do
  factory :bib do |f|
    f.entry_type "エントリ種別１"
    f.abbreviation "略１"
    f.name "書誌情報１"
    f.journal "雑誌名１"
    f.year "2014"
    f.volume "1"
    f.number "1"
    f.pages "100"
    f.month "january"
    f.note "注記１"
    f.key "キー１"
    f.link_url "URL１"
    f.doi "doi１"
    f.authors {
      [ FactoryGirl.create(:author, name: "Test_1"), FactoryGirl.create(:author, name: "Test_2") ]
    }
  end
end
