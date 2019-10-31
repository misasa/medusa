# -*- coding: utf-8 -*-
require 'spec_helper'
require 'webmock/rspec'

describe SesarJson do
  let(:specimen) { FactoryGirl.create(:specimen, igsn: igsn, collector: "採集者", collector_detail: "採集者詳細") }
  let(:igsn) { "IEIMA0005" }
  let(:user_code) { Settings.sesar.user_code }

  before do
    Sesar.logger = Logger.new($stderr)
    WebMock.enable!
  end

  describe ".sync" do
    subject { SesarJson.sync(specimen) }
    let(:get_url) { "https://app.geosamples.org/sample/igsn/#{igsn}" }
    let(:headers) { { "Content-Type" => "application/json" } }

    context "400 Bad Request" do
      let(:response) { "{\"sample\":{\"error\":\"Invalid IGSN #{igsn}: IGSN should be 9 characters (A-Z+0-9).\"}}" }
      before do
        WebMock.stub_request(:get, get_url).to_return(
          body: response,
          status: 400,
          headers: headers)
      end
      it { expect(subject.errors.messages).to eq "Invalid IGSN #{igsn}: IGSN should be 9 characters (A-Z+0-9)." }
    end

    context "403 Forbidden" do
      let(:response) { "{\"sample\":{\"user_code\":\"IEIMA\",\"igsn\":\"#{igsn}\",\"status\":\"The sample metadata is deactived.\"}}" }
      before do
        WebMock.stub_request(:get, get_url).to_return(
          body: response,
          status: 403,
          headers: headers)
      end
      it { expect(subject.errors.messages).to eq "The sample metadata is deactived." }
    end

    context "404 Not Found" do
      let(:response) { "{\"sample\":{\"error\":\"#{igsn} is not registered in SESAR.\"}}" }
      before do
        WebMock.stub_request(:get, get_url).to_return(
          body: response,
          status: 404,
          headers: headers)
      end
      it { expect(subject.errors.messages).to eq "#{igsn} is not registered in SESAR." }
    end

    context "200 Successful" do
      let(:response_body_file) { "#{Rails.root}/spec/fixtures/files/stub_sesar_response.json" }
      before do
        WebMock.stub_request(:get, get_url).to_return(
          body: File.read(response_body_file),
          status: 200,
          headers: headers)
        @response_json = JSON.parse(File.read(response_body_file))
        @response_json = @response_json["sample"]
      end
      it { expect(subject.errors.messages).to be_blank }

      context "レスポンスに各属性の定義がある場合" do
        it "@attributesに値が設定される" do
          expect(subject.attributes["classification"].attributes).to eq SesarJson::Classification.new(@response_json["classification"]).attributes
          expect(subject.attributes["user_code"]).to eq user_code
          expect(subject.attributes["name"]).to eq @response_json["name"]
          expect(subject.attributes["sample_type"]).to eq @response_json["sample_type"]
          expect(subject.attributes["description"]).to eq @response_json["description"]
          expect(subject.attributes["material"]).to eq @response_json["material"]
          expect(subject.attributes["age_min"]).to eq @response_json["age_min"]
          expect(subject.attributes["age_max"]).to eq @response_json["age_max"]
          expect(subject.attributes["age_unit"]).to eq @response_json["age_unit"]
          expect(subject.attributes["size"]).to eq @response_json["size"]
          expect(subject.attributes["size_unit"]).to eq @response_json["size_unit"]
          expect(subject.attributes["collection_start_date"]).to eq @response_json["collection_start_date"]
          expect(subject.attributes["collection_end_date"]).to eq @response_json["collection_end_date"]
          expect(subject.attributes["collection_date_precision"]).to eq @response_json["collection_date_precision"]
          expect(subject.attributes["collector"]).to eq @response_json["collector"]
          expect(subject.attributes["collector_detail"]).to eq @response_json["collector_detail"]
          expect(subject.attributes["latitude"]).to eq @response_json["latitude"]
          expect(subject.attributes["longitude"]).to eq @response_json["longitude"]
          expect(subject.attributes["elevation"]).to eq @response_json["elevation"]
          expect(subject.attributes["locality"]).to eq @response_json["locality"]
          expect(subject.attributes["locality_description"]).to eq @response_json["locality_description"]
          expect(subject.attributes["publish_date"]).to eq @response_json["publish_date"]
          expect(subject.attributes["sample_subtype"]).to eq @response_json["sample_subtype"]
        end
      end

      context "レスポンスに定義なしの属性がある場合" do
        let(:response_body_file) { "#{Rails.root}/spec/fixtures/files/stub_sesar_response_missing_attribute.json" }
        it "@attributesに値が設定される（存在しない属性はnil）" do
          expect(subject.attributes["classification"]).to eq nil
          expect(subject.attributes["user_code"]).to eq user_code
          expect(subject.attributes["name"]).to eq @response_json["name"]
          expect(subject.attributes["sample_type"]).to eq @response_json["sample_type"]
          expect(subject.attributes["description"]).to eq @response_json["description"]
          expect(subject.attributes["material"]).to eq @response_json["material"]
          expect(subject.attributes["age_min"]).to eq @response_json["age_min"]
          expect(subject.attributes["age_max"]).to eq @response_json["age_max"]
          expect(subject.attributes["age_unit"]).to eq @response_json["age_unit"]
          expect(subject.attributes["size"]).to eq @response_json["size"]
          expect(subject.attributes["size_unit"]).to eq @response_json["size_unit"]
          expect(subject.attributes["collection_start_date"]).to eq @response_json["collection_start_date"]
          expect(subject.attributes["collection_end_date"]).to eq @response_json["collection_end_date"]
          expect(subject.attributes["collection_date_precision"]).to eq @response_json["collection_date_precision"]
          expect(subject.attributes["collector"]).to eq @response_json["collector"]
          expect(subject.attributes["collector_detail"]).to eq @response_json["collector_detail"]
          expect(subject.attributes["latitude"]).to eq @response_json["latitude"]
          expect(subject.attributes["longitude"]).to eq @response_json["longitude"]
          expect(subject.attributes["elevation"]).to eq @response_json["elevation"]
          expect(subject.attributes["locality"]).to eq @response_json["locality"]
          expect(subject.attributes["locality_description"]).to eq @response_json["locality_description"]
          expect(subject.attributes["publish_date"]).to eq @response_json["publish_date"]
          expect(subject.attributes["sample_subtype"]).to eq @response_json["sample_subtype"]
        end
      end
    end
  end

  describe "#update_specimen" do
    let(:name) { "sample001" }
    let(:description) { "test" }
    let(:material) { "Rock" }
    let(:sample_name) { "IM0001" }
    let(:sample_type) { "Core" }
    let(:collected_at) { "2007-01-21 00:00:00" }
    let(:collected_end_at) { "2015-06-02T10:00:10Z" }
    let(:age_min) { "1" }
    let(:age_max) { "10" }
    let(:age_unit) { "million years (Ma)" }
    let(:size) { "100" }
    let(:size_unit) { "kg" }
    let(:collection_date_precision) { "time" }
    let(:collector) { "Curator" }
    let(:collector_detail) { "Texas A&M University, Integrated Ocean Drilling Program, College Station, TX, 77845, USA" }
    let(:latitude) { "35.5134" }
    let(:longitude) { "-117.3463" }
    let(:elevation) { "781.4" }
    let(:locality) { "test locality" }
    let(:locality_description) { "for test locality" }
    let(:sesar_classification) { "Igneous>Plutonic" }
    let(:classification) { {"Rock" => {"Igneous" => {"Plutonic" => []}}} }
    let(:classification_obj) { SesarJson::Classification.new(classification) }

    # Relation model.
    let(:places_model) { Place.find_by(latitude: latitude, longitude: longitude, elevation: elevation) }
    let(:physical_form_model) { PhysicalForm.find_by(sesar_sample_type: sample_type) }
    let(:classification_model) { Classification.find_by(sesar_material: material, sesar_classification: sesar_classification) }
    let(:parent_classification_model) { Classification.find_by(sesar_material: material, sesar_classification: parent_sesar_classification) }
    let(:parent_sesar_classification) { nil }

    # Custom attributes.
    let(:publish_date) { "2020-01-01" }
    let(:sample_subtype) { "Specimen" }
    let(:specimen_custom_attribute_1) { FactoryGirl.create(:specimen_custom_attribute, specimen_id: specimen.id, custom_attribute_id: custom_attribute_1.id, value: "2019-12-20") }
    let(:custom_attribute_1) { FactoryGirl.create(:custom_attribute, sesar_name: "publish_date") }
    let(:specimen_custom_attribute_2) { FactoryGirl.create(:specimen_custom_attribute, specimen_id: specimen.id, custom_attribute_id: custom_attribute_2.id, value: "subtype") }
    let(:custom_attribute_2) { FactoryGirl.create(:custom_attribute, sesar_name: "sample_subtype") }
    let(:specimen_custom_attribute_3) { FactoryGirl.create(:specimen_custom_attribute, specimen_id: specimen.id, custom_attribute_id: custom_attribute_3.id, value: "test1,test2") }
    let(:custom_attribute_3) { FactoryGirl.create(:custom_attribute, sesar_name: "sample_other_names") }

    before do
      @sesar_json = SesarJson.new()
      attributes = {}
      attributes["classification"] = classification_obj
      attributes["user_code"] = user_code
      attributes["name"] = name
      attributes["sample_type"] = sample_type
      attributes["description"] = description
      attributes["material"] = material
      attributes["age_min"] = age_min
      attributes["age_max"] = age_max
      attributes["age_unit"] = age_unit
      attributes["size"] = size
      attributes["size_unit"] = size_unit
      attributes["collection_start_date"] = collected_at
      attributes["collection_end_date"] = collected_end_at
      attributes["collection_date_precision"] = collection_date_precision
      attributes["collector"] = collector
      attributes["collector_detail"] = collector_detail
      attributes["latitude"] = latitude
      attributes["longitude"] = longitude
      attributes["elevation"] = elevation
      attributes["locality"] = locality
      attributes["locality_description"] = locality_description
      attributes["publish_date"] = publish_date
      attributes["sample_subtype"] = sample_subtype
      @sesar_json.attributes = attributes
    end

    describe "#get_place_model" do
      subject { @sesar_json.get_place_model(specimen) }
      let(:latitude) { nil }
      let(:longitude) { nil }
      let(:elevation) { nil }
      let(:locality) { nil }
      let(:locality_description) { nil }

      context "位置情報のすべての属性がnilの場合" do
        it { expect(subject).to eq nil }
      end

      context "歯抜けデータの場合" do
        context "latitudeのみnilでない場合" do
          let(:latitude) { "-82.63343" }
          it "以下のオブジェクトを返す" do
            expect(subject.name).to eq "locality of #{specimen.name}"
            expect(subject.description).to eq nil
            expect(subject.latitude).to eq latitude.to_f
            expect(subject.longitude).to eq nil
            expect(subject.elevation).to eq nil
          end
        end
        context "longitudeのみnilでない場合" do
          let(:longitude) { "5.0" }
          it "以下のオブジェクトを返す" do
            expect(subject.name).to eq "locality of #{specimen.name}"
            expect(subject.description).to eq nil
            expect(subject.latitude).to eq nil
            expect(subject.longitude).to eq longitude.to_f
            expect(subject.elevation).to eq nil
          end
        end
        context "elevationのみnilでない場合" do
          let(:elevation) { "1.0" }
          it "以下のオブジェクトを返す" do
            expect(subject.name).to eq "locality of #{specimen.name}"
            expect(subject.description).to eq nil
            expect(subject.latitude).to eq nil
            expect(subject.longitude).to eq nil
            expect(subject.elevation).to eq elevation.to_f
          end
        end
        context "localityのみnilでない場合" do
          let(:locality) { "test" }
          it "以下のオブジェクトを返す" do
            expect(subject.name).to eq locality
            expect(subject.description).to eq nil
            expect(subject.latitude).to eq nil
            expect(subject.longitude).to eq nil
            expect(subject.elevation).to eq nil
          end
        end
        context "locality_descriptionのみnilでない場合" do
          let(:locality_description) { "for test locality" }
          it "以下のオブジェクトを返す" do
            expect(subject.name).to eq "locality of #{specimen.name}"
            expect(subject.description).to eq locality_description
            expect(subject.latitude).to eq nil
            expect(subject.longitude).to eq nil
            expect(subject.elevation).to eq nil
          end
        end
      end

      context "全属性がnilでない場合" do
        let(:latitude) { "1" }
        let(:longitude) { "1" }
        let(:elevation) { "0" }
        let(:locality) { "test" }
        let(:locality_description) { "for test locality" }

        context "該当するplaceが存在する場合" do
          it "見つけたplaceオブジェクトを返す" do
            expect(subject).to eq places_model
          end
          it "新規登録しない" do
            specimen
            expect{ subject }.not_to change{ Place.count }
          end
        end

        context "該当するplaceが存在しない場合" do
          let(:elevation) { "2" }

          it "新規登録したplaceオブジェクトを返す" do
            expect(subject).to eq places_model
          end
          it "新規登録する" do
            specimen
            expect{ subject }.to change{ Place.count }.by(1)
          end
        end
      end
    end

    describe "#get_physical_form_model" do
      subject { @sesar_json.get_physical_form_model(specimen) }

      context "sample_typeがnilの場合" do
        let(:sample_type) { nil }
        it { expect(subject).to eq nil }
      end

      context "sample_typeがnilでない場合" do
        context "該当するphysical_formが存在する場合" do
          let(:sample_type) { "Other" }

          it "見つけたphysical_formオブジェクトを返す" do
            expect(subject).to eq physical_form_model
          end

          it "新規登録しない" do
            specimen
            expect{ subject }.not_to change{ PhysicalForm.count }
          end
        end

        context "該当するphysical_formが存在しない場合" do
          it "登録したphysical_formオブジェクトを返す" do
            expect(subject).to eq physical_form_model
          end
          it "新規登録する" do
            specimen
            expect{ subject }.to change{ PhysicalForm.count }.by(1)
          end
        end
      end
    end

    describe "#get_classification_model" do
      subject { @sesar_json.get_classification_model(specimen) }

      context "レスポンスにclassification属性が存在しない場合" do
        let(:classification_obj) { nil }
        it { expect(subject).to eq nil }
      end

      context "1 level classification -> { 'classification': [] }" do
        let(:classification) { [] }
        it { expect(subject).to eq nil }
      end

      context "2 level classification -> { 'classification': { 'material name': [] } }" do
        let(:classification) { { material => [] } }
        it { expect(subject).to eq nil }
      end

      context "3 level classification -> { 'classification': { 'material name': { 'xxx': [] } } }" do
        let(:classification) { { material => { "Igneous" => [] } } }
        let(:sesar_classification) { "Igneous" }

        context "該当するclassificationsが存在する場合" do
          before do
            FactoryGirl.create(:classification, sesar_classification: sesar_classification)
          end

          it "見つけたclassificationオブジェクトを返す" do
            expect(subject).to eq classification_model
          end

          it "新規登録しない" do
            expect{ subject }.not_to change{ Classification.where(sesar_material: material, sesar_classification: sesar_classification).count }
          end
        end

        context "該当するclassificationsが存在しない場合" do
          it "登録したclassificationオブジェクトを返す" do
            expect(subject).to eq classification_model
          end

          it "新規登録する" do
            expect{ subject }.to change{ Classification.where(sesar_material: material, sesar_classification: sesar_classification).count }.by(1)
          end
        end
      end

      context "4 level classification -> {classification: {'xxx': {'yyy': {'zzz': []}}}}" do
        let(:classification) { { material => { "Igneous" => { "Plutonic" => [] } } } }
        let(:sesar_classification) { "Igneous>Plutonic" }
        let(:parent_sesar_classification) { "Igneous" }

        it "sesar_classificationが「yyy>zzz」のclassificationオブジェクトが返る" do
          expect(subject).to eq classification_model
        end

        context "classificationsに親のclassificationのみ存在する場合" do
          before do
            FactoryGirl.create(:classification, sesar_classification: parent_sesar_classification)
          end
          it "親のレコードが増えない" do
            expect{ subject }.not_to change{ Classification.where(sesar_material: material, sesar_classification: parent_sesar_classification).count }
          end
          it "子の parent_id に検索した親のidが登録される" do
            expect(subject.parent_id).to eq parent_classification_model.id
          end
        end

        context "classificationsに子のclassificationのみ存在する場合" do
          before do
            FactoryGirl.create(:classification, sesar_classification: sesar_classification)
          end
          it "子のレコードが増えない" do
            expect{ subject }.not_to change{ Classification.where(sesar_material: material, sesar_classification: sesar_classification).count }
          end
          it "親のレコードが登録される" do
            expect{ subject }.to change{ Classification.where(sesar_material: material, sesar_classification: parent_sesar_classification).count }.by(1)
          end
        end

        context "classificationsに親子両方のclassificationが存在する場合" do
          before do
            FactoryGirl.create(:classification, sesar_classification: parent_sesar_classification)
            FactoryGirl.create(:classification, sesar_classification: sesar_classification)
          end
          it "レコードが増えない" do
            specimen
            expect{ subject }.not_to change{ Classification.count }
          end
        end

        context "classificationsに親子両方のclassificationが存在しない場合" do
          it "親のレコードが登録される" do
            expect{ subject }.to change{ Classification.where(sesar_material: material, sesar_classification: parent_sesar_classification).count }.by(1)
          end
          it "子のレコードが登録される" do
            expect{ subject }.to change{ Classification.where(sesar_material: material, sesar_classification: sesar_classification).count }.by(1)
          end
          it "子の parent_id に登録した親のidが登録される" do
            expect(subject.parent_id).to eq parent_classification_model.id
          end
        end
      end
    end

    describe "#associate_specimen_custom_attributes" do
      subject{ @sesar_json.associate_specimen_custom_attributes(specimen) }

      context "カスタム属性情報が存在する場合" do
        before do
          specimen_custom_attribute_1
          specimen_custom_attribute_2
          specimen_custom_attribute_3
        end
        it "条件に合致するレコード群が返る" do
          expect(subject).to include specimen_custom_attribute_1
          expect(subject).to include specimen_custom_attribute_2
          expect(subject).not_to include specimen_custom_attribute_3
        end
      end

      context "カスタム属性情報が存在しない場合" do
        it { expect(subject).to eq [] }
      end
    end

    describe "specimens更新結果確認" do
      before do
        @sesar_json.update_specimen(specimen)
      end

      it "specimensテーブルの値が正しく更新されること" do
        expect(specimen.name).to eq name
        expect(specimen.description).to eq description
        expect(specimen.igsn).to eq igsn
        expect(specimen.age_min).to eq age_min.to_f
        expect(specimen.age_max).to eq age_max.to_f
        expect(specimen.age_unit).to eq "Ma"
        expect(specimen.size).to eq size
        expect(specimen.size_unit).to eq size_unit
        expect(specimen.collected_at).to eq DateTime.parse(collected_at)
        expect(specimen.collected_end_at).to eq DateTime.parse(collected_end_at)
        expect(specimen.collection_date_precision).to eq collection_date_precision
        expect(specimen.collector).to eq collector
        expect(specimen.collector_detail).to eq collector_detail
      end

      context "place情報あり" do
        it { expect(specimen.place_id).to eq places_model.id }
      end

      context "place情報なし" do
        let(:latitude) { nil }
        let(:longitude) { nil }
        let(:elevation) { nil }
        let(:locality) { nil }
        let(:locality_description) { nil }
        it { expect(specimen.place_id).to eq nil }
      end

      context "physical_form情報あり" do
        it { expect(specimen.physical_form_id).to eq physical_form_model.id }
      end

      context "physical_form情報なし" do
        let(:sample_type) { nil }
        it { expect(specimen.physical_form_id).to eq nil }
      end

      context "classification情報あり" do
        it { expect(specimen.classification_id).to eq classification_model.id }
      end

      context "classification情報なし" do
        let(:classification_obj) { nil }
        it { expect(specimen.classification_id).to eq nil }
      end
    end

    describe "specimen_custom_attributes更新結果確認" do
      subject { @sesar_json.update_specimen(specimen) }
      context "カスタム属性情報が存在する" do
        before do
          specimen_custom_attribute_1
          specimen_custom_attribute_2
          subject
        end

        it "specimen_custom_attributesテーブルの値が正しく更新される" do
          expect(specimen_custom_attribute_1.reload.value).to eq publish_date
          expect(specimen_custom_attribute_2.reload.value).to eq sample_subtype
        end
      end

      context "カスタム属性情報が存在しない" do
        it { expect{ subject }.not_to change{ SpecimenCustomAttribute } }
      end
    end

    describe "#elevation_conversion" do
      subject { @sesar_json.elevation_conversion(elevation, elevation_unit) }
      let(:elevation) { "100" }
      let(:elevation_unit) { nil }

      context "elevation nil" do
        let(:elevation) { nil }
        it { expect(subject).to eq nil }
      end
      context "elevation_unit nil" do
        it { expect(subject).to eq elevation.to_f }
      end
      context "meters" do
        let(:elevation_unit) { "meters" }
        it { expect(subject).to eq elevation.to_f }
      end
      context "kilometers" do
        let(:elevation_unit) { "kilometers" }
        it { expect(subject).to eq elevation.to_f.kilometers.to.meters.value }
      end
      context "feet" do
        let(:elevation_unit) { "feet" }
        it { expect(subject).to eq elevation.to_f.feet.to.meters.value }
      end
      context "miles" do
        let(:elevation_unit) { "miles" }
        it { expect(subject).to eq elevation.to_f.miles.to.meters.value }
      end
    end
  end
end

WebMock.allow_net_connect!
