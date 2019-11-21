# -*- coding: utf-8 -*-
require 'spec_helper'

describe Sesar do
  let(:geocoder_obj){ double(:geocoder_obj) }
  let(:geocoder_response) { {"display_name"=>"Nishiwaki, Hyogo Prefecture, Kinki Region, Japan", "address"=>{"city"=>"Nishiwaki", "state"=>"Kinki Region", "country"=>"Japan"}} }

  before do
    Sesar.logger = Logger.new($stderr)
    allow(geocoder_obj).to receive(:address).and_return(geocoder_response['display_name'])
    allow(geocoder_obj).to receive(:country).and_return(geocoder_response['address']['country'])
    allow(geocoder_obj).to receive(:state).and_return(geocoder_response['address']['state'])
    allow(geocoder_obj).to receive(:city).and_return(geocoder_response['address']['city'])
    allow(Geocoder).to receive(:search).and_return([geocoder_obj])
  end

  describe ".sync" do
    subject { Sesar.sync(specimen) }
    let(:specimen) { FactoryGirl.create(:specimen, igsn: igsn, collector: "採集者", collector_detail: "採集者詳細", collection_date_precision: "date", collected_at: "20150101") }
    let(:bib) { FactoryGirl.create(:bib) }
    let(:material) {"Rock"}
    let(:sesar_classification) {"Igneous"}
    let(:igsn) { "JEDRM001X" }
    let(:sesar_obj) { double("sesar_obj") }
    let(:sesar_sample) { double("sesar_sample", name: sample_name, sample_type: sample_type) }
    let(:sample_name) {"IM0001"}
    let(:sample_type) {"Core"}


    before do
        specimen.bibs << bib
        specimen.physical_form.name = "asteroid"
        specimen.classification.sesar_material = material
        specimen.classification.sesar_classification = sesar_classification
        specimen.place.latitude = 35
        specimen.place.longitude = 135
        allow(sesar_obj).to receive(:sample).and_return(sesar_sample)
        allow(Sesar).to receive(:find).with(igsn).and_return(sesar_obj)
        subject
    end

    it {
      expect(specimen.name).to be_eql(sample_name)
      expect(specimen.physical_form.sesar_sample_type).to be_eql(sample_type)
    }
  end

  describe ".from_active_record(model)" do
    subject { Sesar.from_active_record(specimen) }
    let(:specimen) { FactoryGirl.create(:specimen, collector: "採集者", collector_detail: "採集者詳細", collection_date_precision: "date", collected_at: "20150101", collected_end_at: "20150202") }
    let(:bib) { FactoryGirl.create(:bib) }
    let(:material) {"Rock"}
    let(:sesar_classification) {"Igneous"}

    before do
      specimen.bibs << bib
      specimen.physical_form.name = "asteroid"
      specimen.classification.sesar_material = material
      specimen.classification.sesar_classification = sesar_classification
      specimen.place.latitude = 35
      specimen.place.longitude = 135
    end

    it "正しく値が設定される" do
      sesar = subject
      expect(sesar.attributes["sample_type"]).to eq "Other"
      expect(sesar.attributes["name"]).to eq specimen.name
      expect(sesar.attributes["material"]).to eq specimen.classification.sesar_material
      expect(sesar.attributes["igsn"]).to eq specimen.igsn
      expect(sesar.attributes["age_min"]).to eq specimen.age_min
      expect(sesar.attributes["age_max"]).to eq specimen.age_max
      expect(sesar.attributes["age_unit"]).to eq "years"
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
      expect(sesar.attributes["collection_end_date"]).to eq "2015-02-02T00:00:00Z"
      expect(sesar.attributes["collection_date_precision"]).to eq specimen.collection_date_precision
      expect(sesar.attributes["current_archive"]).to eq "Institute for Study of the Earth's Interior Okayama University"
      expect(sesar.attributes["current_archive_contact"]).to eq "tkk@misasa.okayama-u.ac.kp"
      expect(sesar.attributes["description"]).to eq specimen.description
      expect(sesar.attributes["sample_other_names"]).to eq [specimen.global_id]
    end

    context "elevation is blank" do
      before do
        specimen.place.elevation = nil
      end
      it { expect(subject.attributes[:elevation_unit]).to be_blank }
    end
    context "elevation is not blank" do
      it { expect(subject.attributes[:elevation_unit]).to eq "meters" }
    end
    context "classification is blank" do
      before do
        specimen.classification = nil
      end
      it { expect(subject.attributes[:classification]).to be_blank }
    end
    context "classification is not blank" do
      it { expect(subject.attributes[:classification]).to eq ["Rock", "Igneous"] }
    end
    context "place is blank" do
      before do
        specimen.place = nil
      end
      it { expect(subject.attributes[:country_id]).to be_blank }
    end
    context "place is not blank" do
      it { expect(subject.attributes.has_key?(:country_id)).to eq false }
    end

    describe "to_xml" do
      before do
        sesar = Sesar.from_active_record(specimen)
        @xml = sesar.to_xml
      end
      context "Specimen レコードがIGSN属性を持たない" do
        let(:specimen) { FactoryGirl.create(:specimen, igsn: nil) }
        it { expect(@xml).to include "xsi:schemaLocation=\"http://app.geosamples.org/4.0/sample.xsd\"" }
        it { expect(@xml).to include "<user_code>#{Settings.sesar.user_code}</user_code>" }
        it { expect(@xml).not_to include "<igsn>" }

        context "classification is blank" do
          before do
            specimen.classification = nil
            sesar = Sesar.from_active_record(specimen)
            @xml = sesar.to_xml
          end
          it { expect(@xml).not_to include "<material>" }
          it { expect(@xml).not_to include "<classification>" }
        end
      end
      context "Specimen レコードがIGSN属性を持つ" do
        it { expect(@xml).to include "xsi:schemaLocation=\"http://app.geosamples.org/4.0/updateSample.xsd\"" }
        it { expect(@xml).not_to include "<user_code>" }
        it { expect(@xml).to include "<igsn>" }

        context "attributes value is blank" do
          before do
            specimen.collected_end_at = nil
            sesar = Sesar.from_active_record(specimen)
            @xml = sesar.to_xml
          end
          it { expect(@xml).to include "<collection_end_date/>" }
        end
        context "classification is blank" do
          before do
            specimen.classification = nil
            sesar = Sesar.from_active_record(specimen)
            @xml = sesar.to_xml
          end
          it { expect(@xml).to include "<material></material>" }
          it { expect(@xml).to include "xsi:schemaLocation=\"http://app.geosamples.org/classifications.xsd\"></classification>" }
        end
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
        it { expect(@xml).to include "<sample_other_names><sample_other_name>#{specimen.global_id}</sample_other_name></sample_other_names>" }
      end
      context "external_urls" do
        it { expect(@xml).to include "<external_urls><external_url><url>http://dream.misasa.okayama-u.ac.jp/?q=#{specimen.global_id}</url><description/><url_type>regular URL</url_type></external_url><external_url><url>https://doi.org/doi１</url><description>書誌情報１</description><url_type>DOI</url_type></external_url></external_urls>" }
      end
    end

    context "with custom_attribute" do
      let(:specimen_custom_attribute_1) { FactoryGirl.create(:specimen_custom_attribute, specimen_id: specimen.id, custom_attribute_id: custom_attribute_1.id, value: "value") }
      let(:custom_attribute_1) { FactoryGirl.create(:custom_attribute, sesar_name: "sample_comment") }
      let(:specimen_custom_attribute_2) { FactoryGirl.create(:specimen_custom_attribute, specimen_id: specimen.id, custom_attribute_id: custom_attribute_2.id, value: "name_1,name_2") }
      let(:custom_attribute_2) { FactoryGirl.create(:custom_attribute, sesar_name: "sample_other_names") }
      before do
        specimen_custom_attribute_1
        specimen_custom_attribute_2
      end
      it "正しく値が設定される" do
        sesar = Sesar.from_active_record(specimen)
        expect(sesar.attributes[custom_attribute_1.sesar_name]).to eq(specimen_custom_attribute_1.value)
        expect(sesar.attributes[custom_attribute_2.sesar_name]).to eq([specimen.global_id].concat(specimen_custom_attribute_2.value.split(",")))
      end
      describe "to_xml" do
        before do
          sesar = Sesar.from_active_record(specimen)
          @xml = sesar.to_xml
        end
        context "sample_other_names" do
          it { expect(@xml).to include "<sample_other_names><sample_other_name>#{specimen.global_id}</sample_other_name><sample_other_name>name_1</sample_other_name><sample_other_name>name_2</sample_other_name></sample_other_names>" }
        end
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
  
  describe "緯度経度から場所を特定" do
    describe ".country_name(result)" do
      subject { Sesar.country_name(result) }
      context "countryの情報が存在する場合" do
        let(:result) { geocoder_obj }
        it { expect(subject).to eq "Japan" }
      end
      context "countryの情報が存在しない場合" do
        let(:result) { nil }
        it { expect(subject).to eq "" }
      end
      context "countryの情報が存在しない場合(geocoderのレスポンスがエラー)" do
        before do
          geocoder_error = {"error"=>"Unable to geocode"}
          allow(geocoder_obj).to receive(:address).and_return(geocoder_error['display_name'])
        end
        let(:result) { geocoder_obj }
        it { expect(subject).to eq "" }
      end
    end
  
    describe ".province_name(result)" do
      subject { Sesar.province_name(result) }
      context "provinceの情報(state)が存在する場合" do
        let(:result) { geocoder_obj }
        it { expect(subject).to eq "Kinki Region" }
      end
      context "provinceの情報が存在しない場合" do
        let(:result) { nil }
        it { expect(subject).to eq "" }
      end
      context "provinceの情報が存在しない場合(geocoderのレスポンスがエラー)" do
        before do
          geocoder_error = {"error"=>"Unable to geocode"}
          allow(geocoder_obj).to receive(:address).and_return(geocoder_error['display_name'])
        end
        let(:result) { geocoder_obj }
        it { expect(subject).to eq "" }
      end
    end
  
    describe ".city_name(result)" do
      subject { Sesar.city_name(result) }
      context "cityの情報が存在する場合" do
        let(:result) { geocoder_obj }
        it { expect(subject).to eq "Nishiwaki" }
      end
      context "cityの情報が存在しない場合" do
        let(:result) { nil }
        it { expect(subject).to eq "" }
      end
      context "cityの情報が存在しない場合(geocoderのレスポンスがエラー)" do
        before do
          geocoder_error = {"error"=>"Unable to geocode"}
          allow(geocoder_obj).to receive(:address).and_return(geocoder_error['display_name'])
        end
        let(:result) { geocoder_obj }
        it { expect(subject).to eq "" }
      end
    end
    
    describe ".external_url(model)" do
      subject {Sesar.external_url(model) }
      let(:data){YAML.load_file(file_yaml)}
      let(:file_yaml){Rails.root.join("config", "application.yml").to_path}
      before do 
        data["defaults"]["sesar"]["external_urls"][0]["description"] = nil
        data["defaults"]["sesar"]["external_urls"][0]["url_type"] = "regular URL"
        File.open(file_yaml,"w"){|f| f.write data.to_yaml}
        Settings.reload!
      end
      context "紐づくbibが存在しない場合" do
        let(:model) { FactoryGirl.create(:specimen, igsn: "") }
        it { expect(subject).to include({description: nil, url_type: "regular URL", url: "http://dream.misasa.okayama-u.ac.jp/?q=#{model.global_id}"}) }
        it { expect(subject).to_not include({url: "https://doi.org/doi１", description: "書誌情報１", url_type: "DOI"}) }
      end
      context "紐づくbibが存在する場合" do
        let(:model) { FactoryGirl.create(:specimen, igsn: "") }
        let(:bib) { FactoryGirl.create(:bib) }
        before do
          model.bibs << bib
        end        
        it { expect(subject).to include({url: "https://doi.org/doi１", description: "書誌情報１", url_type: "DOI"}) }
        context "doi is nil" do
          let(:bib) { FactoryGirl.create(:bib, doi: nil)}
          it { expect(subject).not_to include({url: "https://doi.org/", description: "書誌情報１", url_type: "DOI"}) }
        end

        context "doi is ''" do
          let(:bib) { FactoryGirl.create(:bib, doi: "")}
          it { expect(subject).not_to include({url: "https://doi.org/", description: "書誌情報１", url_type: "DOI"}) }
        end

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

  describe ".igsn_registered?" do
    subject { sesar.igsn_registered? }
    let(:sesar) { Sesar.from_active_record(specimen) }
    let(:specimen) { FactoryGirl.create(:specimen, igsn: igsn) }
    let(:igsn) { "IEAAA0001" }

    context "specimenレコードがigsn属性を持つ" do
      it { expect(subject).to eq true }
    end
    context "specimenレコードがigsn属性を持たない" do
      let(:igsn) { nil }
      it { expect(subject).to eq false }
    end
    context "specimenレコードのigsn属性が空" do
      let(:igsn) { "" }
      it { expect(subject).to eq false }
    end
  end

  describe ".age_unit_conversion" do
    subject { Sesar.age_unit_conversion(age_unit) }
    context "age_unitがblank" do
      let(:age_unit) { nil }
      it { expect(subject).to eq "" }
    end
    context "age_unitが'a'" do
      let(:age_unit) { "a" }
      it { expect(subject).to eq "years" }
    end
    context "age_unitが'a'以外かつ設定ファイルに定義されている" do
      let(:age_unit) { "Ma" }
      it { expect(subject).to eq "million years (Ma)" }
    end
    context "age_unitが設定ファイルに定義されていない" do
      let(:age_unit) { "other" }
      it { expect(subject).to eq "other" }
    end
  end

end
