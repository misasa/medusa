require 'spec_helper'

describe Sesar do

  describe ".from_active_record(model)" do
    let(:specimen) { FactoryGirl.create(:specimen, collector: "採集者", collector_detail: "採集者詳細", collection_date_precision: "date", collected_at: "20150101") }
    let(:bib) { FactoryGirl.create(:bib) }
    let(:material) {"Rock"}
    let(:sesar_classification) {"Igneous"}
    let(:specimen_custom_attribute_1) { FactoryGirl.create(:specimen_custom_attribute, specimen_id: specimen.id, custom_attribute_id: custom_attribute_1.id, value: "value") }
    let(:custom_attribute_1) { FactoryGirl.create(:custom_attribute, sesar_name: "sample_comment") }
    let(:specimen_custom_attribute_2) { FactoryGirl.create(:specimen_custom_attribute, specimen_id: specimen.id, custom_attribute_id: custom_attribute_2.id, value: "name_1,name_2") }
    let(:custom_attribute_2) { FactoryGirl.create(:custom_attribute, sesar_name: "sample_other_names") }
    before do
      specimen_custom_attribute_1
      specimen_custom_attribute_2
      specimen.bibs << bib
      specimen.physical_form.name = "asteroid"
      specimen.classification.sesar_material = material
      specimen.classification.sesar_classification = sesar_classification
      specimen.place.latitude = 35
      specimen.place.longitude = 135
    end
    it "正しく値が設定される" do
      sesar = Sesar.from_active_record(specimen)
      expect(sesar.attributes["sample_type"]).to eq "Other"
      expect(sesar.attributes["name"]).to eq specimen.name
      expect(sesar.attributes["material"]).to eq specimen.classification.sesar_material
      expect(sesar.attributes["igsn"]).to eq specimen.igsn
      expect(sesar.attributes["age_min"]).to eq specimen.age_min
      expect(sesar.attributes["age_max"]).to eq specimen.age_max
      expect(sesar.attributes["age_unit"]).to eq specimen.age_unit
      expect(sesar.attributes["size"]).to eq specimen.size
      expect(sesar.attributes["size_unit"]).to eq specimen.size_unit
      expect(sesar.attributes["latitude"]).to eq specimen.place.latitude
      expect(sesar.attributes["longitude"]).to eq specimen.place.longitude
      expect(sesar.attributes["elevation"]).to eq specimen.place.elevation
      expect(sesar.attributes["locality"]).to eq specimen.place.name
      expect(sesar.attributes["locality_description"]).to eq specimen.place.description
      expect(sesar.attributes["collector"]).to eq specimen.collector
      expect(sesar.attributes["collector_detail"]).to eq specimen.collector_detail
      expect(sesar.attributes["collection_start_date"]).to eq "2015-01-01T00:00:00Z"
      expect(sesar.attributes["collection_end_date"]).to eq "2015-01-01T00:00:00Z"
      expect(sesar.attributes["collection_date_precision"]).to eq specimen.collection_date_precision
      expect(sesar.attributes["current_archive"]).to eq "Institute for Study of the Earth's Interior Okayama University"
      expect(sesar.attributes["current_archive_contact"]).to eq "tkk@misasa.okayama-u.ac.kp"
      expect(sesar.attributes["description"]).to eq specimen.description
      expect(sesar.attributes[custom_attribute_1.sesar_name]).to eq(specimen_custom_attribute_1.value)
      expect(sesar.attributes[custom_attribute_2.sesar_name]).to eq(specimen_custom_attribute_2.value.split(","))
    end
    describe "to_xml" do
      before do
        sesar = Sesar.from_active_record(specimen)
        @xml = sesar.to_xml
      end
      context "materialが>を含む" do
        let(:material) {"Liquid>aqueous"}
        let(:sesar_classification) {""}
        it { expect(@xml).to include "<material>Liquid>aqueous</material>" }
      end
      context "materialが>を含まない" do
        let(:material) {"Gas"}
        let(:sesar_classification) {""}
        it { expect(@xml).to include "<material>Gas</material>" }
      end
      context "classificationがTypeを含む" do
        let(:sesar_classification) {"Igneous>Volcanic>VolcanicType>Felsic"}
        it { expect(@xml).to include "<Rock><Igneous><Volcanic><VolcanicType>Felsic</VolcanicType></Volcanic></Igneous></Rock></classification>" }
      end
      context "classificationがTypeを含まない" do
        it { expect(@xml).to include "<Rock><Igneous/></Rock></classification>" }
      end
      context "sample_other_names" do
        it { expect(@xml).to include "<sample_other_names><sample_other_name>name_1</sample_other_name><sample_other_name>name_2</sample_other_name></sample_other_names>" }
      end
      context "external_urls" do
        it { expect(@xml).to include "<external_urls><external_url><url>http://dream.misasa.okayama-u.ac.jp/?igsn=#{specimen.igsn}</url><description/><url_type>regular URL</url_type></external_url><external_url><url>http://dx.doi.org/doi１</url><description>書誌情報１</description><url_type>DOI</url_type></external_url></external_urls>" }
      end
    end
  end
  
  describe ".array_classification(classification)" do
    subject { Sesar.array_classification(classification) }
    let(:classification) { FactoryGirl.create(:classification, sesar_classification: sesar_classification) }
    context "sesar_classificationに値が設定されている" do
      let(:sesar_classification) {"Igneous>Volcanic>VolcanicType>Felsic"}
      it { expect(subject).to eq ["Rock","Igneous","Volcanic","VolcanicType","Felsic"] }
    end
    context "sesar_classificationがblank" do
      let(:sesar_classification) {""}
      it { expect(subject).to eq "" }
    end
    context "classificationがblank" do
      let(:classification) {""}
      it { expect(subject).to eq "" }
    end
  end
  
  describe ".physical_form_conversion(physical_form)" do
    context "physical_formがblank" do
      it { expect(Sesar.physical_form_conversion("")).to eq "" }
    end
    context "physical_formがblankではない" do
      subject { Sesar.physical_form_conversion(FactoryGirl.create(:physical_form, name: name)) }
      context "aliquot, on mount, grain, hand specimen, chunk" do
        let(:name) { "aliquot" }
        it { expect(subject).to eq "Individual Sample" }
        let(:name) { "on_mount" }
        it { expect(subject).to eq "Individual Sample" }
        let(:name) { "grain" }
        it { expect(subject).to eq "Individual Sample" } 
        let(:name) { "hand specimen" }
        it { expect(subject).to eq "Individual Sample" }
        let(:name) { "chunk" }
        it { expect(subject).to eq "Individual Sample" }
      end
      context "asteroid, electronics, tool, package" do
        let(:name) { "asteroid" }
        it { expect(subject).to eq "Other" }
        let(:name) { "electronics" }
        it { expect(subject).to eq "Other" }
        let(:name) { "tool" }
        it { expect(subject).to eq "Other" }
        let(:name) { "package" }
        it { expect(subject).to eq "Other" }
      end
      context "powder, thin section" do
        let(:name) { "powder" }
        it { expect(subject).to eq "Thin Section" }
        let(:name) { "thin section" }
        it { expect(subject).to eq "Thin Section" }
      end
      context "drill-cored" do
        let(:name) { "drill-cored" }
        it { expect(subject).to eq "Core" }
      end
      context "solution" do
        let(:name) { "solution" }
        it { expect(subject).to eq "Liquid" }
      end
      context "fraction" do
        let(:name) { "fraction" }
        it { expect(subject).to eq "Mechanical Fraction" }
      end
      context "thick section" do
        let(:name) { "thick section" }
        it { expect(subject).to eq "Slab" }
      end
    end
  end
  describe "緯度経度から場所を特定" do
    let(:result) { Geocoder.search("35,135")[0] }
    describe ".country_name(result)" do
      subject { Sesar.country_name(result) }
      context "countryの情報が存在する場合" do
        it { expect(subject).to eq "Japan" }
      end
      context "countryの情報が存在しない場合" do
        let(:result) { "" }
        it { expect(subject).to eq "" }
      end
    end
  
    describe ".province_name(result)" do
      subject {Sesar.province_name(result) }
      context "provinceの情報(administrative_area_level_1)が存在する場合" do
        it { expect(subject).to eq "Hyōgo-ken" }
      end
      context "provinceの情報(administrative_area_level_1)が存在しない場合" do
        let(:result) { "" }
        it { expect(subject).to eq "" }
      end
    end
  
    describe ".city_name(result)" do
      subject {Sesar.city_name(result) }
      context "cityの情報(locality)が存在する場合" do
        it { expect(subject).to eq "Nishiwaki-shi" }
      end
      context "cityの情報(locality)が複数存在する場合" do
        let(:result) { Geocoder.search("38,141")[0] }
        it { expect(subject).to eq "Watari-gunWatari-chō" }
      end
      context "cityの情報が存在しない場合" do
        let(:result) { "" }
        it { expect(subject).to eq "" }
      end
    end
    
    describe ".external_url(model)" do
      subject {Sesar.external_url(model) }
      let(:data){YAML.load_file(file_yaml)}
      let(:file_yaml){Rails.root.join("config", "application.yml").to_path}
      before do 
        data["defaults"]["sesar"]["external_urls"]["description"] = nil
        data["defaults"]["sesar"]["external_urls"]["url_type"] = "regular URL"
        File.open(file_yaml,"w"){|f| f.write data.to_yaml}
        Settings.reload!
      end
      context "紐づくbibが存在しない場合" do
        let(:model) { FactoryGirl.create(:specimen, igsn: "") }
        it { expect(subject).to include({"description"=>nil,"url_type"=>"regular URL","url"=>"http://dream.misasa.okayama-u.ac.jp/?igsn="}) }
        it { expect(subject).to_not include({url: "http://dx.doi.org/doi１", description: "書誌情報１", url_type: "DOI"}) }
      end
      context "紐づくbibが存在する場合" do
        let(:model) { FactoryGirl.create(:specimen, igsn: "") }
        let(:bib) { FactoryGirl.create(:bib) }
        before do
          model.bibs << bib
        end
        it { expect(subject).to include({url: "http://dx.doi.org/doi１", description: "書誌情報１", url_type: "DOI"}) }
      end
    end
  end

  describe ".associate_specimen_custom_attributes" do
    subject { Sesar.associate_specimen_custom_attributes(specimen) }
    let(:specimen) { FactoryGirl.create(:specimen) }
    let(:specimen_custom_attribute_1) { FactoryGirl.create(:specimen_custom_attribute, specimen_id: specimen.id, custom_attribute_id: custom_attribute_1.id, value: value_1) }
    let(:specimen_custom_attribute_2) { FactoryGirl.create(:specimen_custom_attribute, specimen_id: specimen.id, custom_attribute_id: custom_attribute_2.id, value: value_2) }
    let(:value_1) { "value_1" }
    let(:value_2) { "value_2" }
    let(:custom_attribute_1) { FactoryGirl.create(:custom_attribute, sesar_name: sesar_name_1) }
    let(:custom_attribute_2) { FactoryGirl.create(:custom_attribute, sesar_name: sesar_name_2) }
    let(:sesar_name_1) { "sesar_name_1" }
    let(:sesar_name_2) { "sesar_name_2" }
    context "specimen not associate specimen_custom_attribute" do
      it { expect(subject).to be_blank }
    end
    context "specimen associate 1 specimen_custom_attribute" do
      before { specimen_custom_attribute_1 }
      context "specimen_custom_attribute.value is present" do
        context "custom_attribute.sesar_name is present" do
          it { expect(subject.size).to eq 1 }
          it { expect(subject[0]).to eq(specimen_custom_attribute_1) }
        end
        context "custom_attribute.sesar_name is blank" do
          let(:sesar_name_1) { "" }
          it { expect(subject).to be_blank }
        end
      end
      context "specimen_custom_attribute.value is blank" do
        let(:value_1) { "" }
        context "custom_attribute.sesar_name is present" do
          it { expect(subject).to be_blank }
        end
        context "custom_attribute.sesar_name is blank" do
          let(:sesar_name_1) { "" }
          it { expect(subject).to be_blank }
        end
      end
    end
    context "specimen associate 2 specimen_custom_attributes" do
      before do
        specimen_custom_attribute_1
        specimen_custom_attribute_2
      end
      context "both value is present" do
        context "both sesar_name is present" do
          it { expect(subject.size).to eq 2 }
          it { expect(subject).to include(specimen_custom_attribute_1, specimen_custom_attribute_2) }
        end
        context "1 sesar_name is blank" do
          let(:sesar_name_1) { "" }
          it { expect(subject.size).to eq 1 }
          it { expect(subject[0]).to eq(specimen_custom_attribute_2) }
        end
        context "both sesar_name is blank" do
          let(:sesar_name_1) { "" }
          let(:sesar_name_2) { "" }
          it { expect(subject).to be_blank }
        end
      end
      context "1 value is blank" do
        let(:value_1) { "" }
        context "both sesar_name is present" do
          it { expect(subject.size).to eq 1 }
          it { expect(subject[0]).to eq(specimen_custom_attribute_2) }
        end
        context "1 sesar_name is blank" do
          let(:sesar_name_1) { "" }
          it { expect(subject.size).to eq 1 }
          it { expect(subject[0]).to eq(specimen_custom_attribute_2) }
        end
        context "another sesar_name is blank" do
          let(:sesar_name_2) { "" }
          it { expect(subject).to be_blank }
        end
        context "both sesar_name is blank" do
          let(:sesar_name_1) { "" }
          let(:sesar_name_2) { "" }
          it { expect(subject).to be_blank }
        end
      end
      context "both value is blank" do
        let(:value_1) { "" }
        let(:value_2) { "" }
        context "both sesar_name is present" do
          it { expect(subject).to be_blank }
        end
        context "1 sesar_name is blank" do
          let(:sesar_name_1) { "" }
          it { expect(subject).to be_blank }
        end
        context "both sesar_name is blank" do
          let(:sesar_name_1) { "" }
          let(:sesar_name_2) { "" }
          it { expect(subject).to be_blank }
        end
      end
    end
  end

end
