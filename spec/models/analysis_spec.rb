# -*- coding: utf-8 -*-
require 'spec_helper'

describe Analysis do

  describe "constants" do
    describe "PERMIT_IMPORT_TYPES" do
      subject { Analysis::PERMIT_IMPORT_TYPES }
      it { expect(subject).to include("text/plain", "text/csv", "application/csv", "application/vnd.ms-excel") }
    end
  end

  describe "validates" do
    describe "name" do
      let(:obj) { FactoryGirl.build(:analysis, name: name) }
      context "is presence" do
        let(:name) { "sample_analysis" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:name) { "" }
        it { expect(obj).not_to be_valid }
      end
      context "is 255 characters" do
        let(:name) { "a" * 255 }
        it { expect(obj).to be_valid }
      end
      context "is 256 characters" do
        let(:name) { "a" * 256 }
        it { expect(obj).not_to be_valid }
      end
    end
  end

  describe "#chemistry_summary" do
    let(:analysis) { FactoryGirl.create(:analysis) }
    let(:chemistries) { [chemistry_1, chemistry_2] }
    let(:chemistry_1) { FactoryGirl.build(:chemistry, analysis: analysis, measurement_item: measurement_item_1) }
    let(:chemistry_2) { FactoryGirl.build(:chemistry, analysis: analysis, measurement_item: measurement_item_2) }
    let(:measurement_item_1) { FactoryGirl.create(:measurement_item) }
    let(:measurement_item_2) { FactoryGirl.create(:measurement_item) }
    let(:display_name_1) { "display_name_1" }
    let(:display_name_2) { "display_name_2" }
    before do
      allow(analysis).to receive(:chemistries).and_return(chemistries)
      allow(chemistry_1).to receive(:display_name).and_return(display_name_1)
      allow(chemistry_2).to receive(:display_name).and_return(display_name_2)
    end
    context "method call with no argument" do
      subject { analysis.chemistry_summary }
      context "chemistry.measurement_item is present" do
        it { expect(subject).to eq "display_name_1, display_name_2" }
      end
      context "chemistry.measurement_item is present and display_name is 90 characters" do
        let(:display_name_1) { "a" * 90 }
        let(:display_name_2) { "b" * 90 }
        it { expect(subject).to eq(display_name_1 + ", " + "bbbbb...") }
      end
      context "chemistry.measurement_item is blank" do
        let(:chemistry_1) { FactoryGirl.build(:chemistry, analysis: analysis, measurement_item: nil) }
        let(:chemistry_2) { FactoryGirl.build(:chemistry, analysis: analysis, measurement_item: nil) }
        it { expect(subject).to eq "" }
      end
    end
    context "method call with 50" do
      subject { analysis.chemistry_summary(50) }
      context "chemistry.measurement_item is present" do
        it { expect(subject).to eq "display_name_1, display_name_2" }
      end
      context "chemistry.measurement_item is present and display_name is 90 characters" do
        let(:display_name_1) { "a" * 90 }
        let(:display_name_2) { "b" * 90 }
        it { expect(subject).to eq("a" * 47 + "...") }
      end
      context "chemistry.measurement_item is blank" do
        let(:chemistry_1) { FactoryGirl.build(:chemistry, analysis: analysis, measurement_item: nil) }
        let(:chemistry_2) { FactoryGirl.build(:chemistry, analysis: analysis, measurement_item: nil) }
        it { expect(subject).to eq "" }
      end
    end
  end

  describe "specimen_global_id" do
    let(:specimen){FactoryGirl.create(:specimen)}
    let(:analysis){FactoryGirl.create(:analysis)}
    context "get" do
      context "specimen_id is nil" do
        before{analysis.specimen_id = nil}
        it {expect(analysis.specimen_global_id).to be_blank}
      end
      context "specimen_id is ng" do
        before{analysis.specimen_id = 0}
        it {expect(analysis.specimen_global_id).to be_blank}
      end
      context "specimen_id is ok" do
        before{analysis.specimen_id = specimen.id}
        it {expect(analysis.specimen_global_id).to eq specimen.global_id}
      end
    end
    context "set" do
      context "specimen_global_id is nil" do
        before{analysis.specimen_global_id = nil}
        it {expect(analysis.specimen).to be_blank}
      end
      context "specimen_global_id is ng" do
        before{analysis.specimen_global_id = "xxxxxxxxxxxxxxxxx"}
        it {expect(analysis.specimen).to be_blank}
      end
      context "specimen_global_id is ok" do
        before{analysis.specimen_global_id = specimen.global_id}
        it {expect(analysis.specimen).to eq specimen}
      end
    end
  end

  describe "#device_name=" do
    before { analysis.device_name = name }
    let(:analysis) { FactoryGirl.build(:analysis, device: nil) }
    context "name is exist device name" do
      let(:name) { device.name }
      let(:device) { FactoryGirl.create(:device) }
      it { expect(analysis.device_id).to eq device.id }
    end
    context "name is not device name" do
      let(:name) { "hoge" }
      it { expect(analysis.device_id).to be_nil }
    end
  end

  describe "#technique_name=" do
    before { analysis.technique_name = name }
    let(:analysis) { FactoryGirl.build(:analysis, technique: nil) }
    context "name is exist technique name" do
      let(:name) { technique.name }
      let(:technique) { FactoryGirl.create(:technique) }
      it { expect(analysis.technique_id).to eq technique.id }
    end
    context "name is not technique name" do
      let(:name) { "hoge" }
      it { expect(analysis.technique_id).to be_nil }
    end
  end

  describe ".import_csv" do
    subject { Analysis.import_csv(file) }
    context "file is nil" do
      let(:file) { nil }
      it { expect(subject).to be_nil }
    end
    context "file is present" do
      let(:file) { double(:file) }
      let(:objects) { [analysis] }
      before do
        allow(file).to receive(:content_type).and_return(content_type)
        allow(Analysis).to receive(:build_objects_from_csv).with(file).and_return(objects)
      end
      context "content_type is 'csv'" do
        let(:content_type) { 'text/csv' }
        context "objects is all valid" do
          let(:analysis) { FactoryGirl.build(:analysis) }
          it { expect(subject).to be_present }
          it { expect{subject}.to change(Analysis, :count)}
        end

        context "objects is all valid with chemistries" do
          let(:analysis) { FactoryGirl.build(:analysis) }
          let(:nickname) { "nickname" }
          let(:unit_name) { nil }
          let(:data) { " 10 " }
          let(:measurement_item) { FactoryGirl.create(:measurement_item, nickname: nickname, unit_id: unit.id) }
          let(:unit) { FactoryGirl.create(:unit, name: "parts_per_gram") }
          before do
            unit
            measurement_item
            analysis
            analysis.set_chemistry(nickname, unit_name, data)
          end
          it { expect(1).to be_equal(1)}
          it { expect(subject).to be_present }
          it { expect{subject}.to change(Analysis, :count)}
          it { expect{subject}.to change(Chemistry, :count)}
        end

        context "object is invalid" do
          let(:analysis) { FactoryGirl.build(:analysis, name: nil) }
          it { expect(subject).to eq false }
        end
      end
      context "content_type is not 'csv'" do
        let(:content_type) { 'image/png' }
        context "objects is all valid" do
          let(:analysis) { FactoryGirl.build(:analysis) }
          it { expect(subject).to be_nil }
        end
        context "object is invalid" do
          let(:analysis) { FactoryGirl.build(:analysis, name: nil) }
          it { expect(subject).to be_nil }
        end
      end
    end
  end

  describe ".build_objects_from_csv" do
    subject { Analysis.build_objects_from_csv(file) }
    let(:file) { double(:file) }
    let(:csv_read) { [["header ", nil], [row_1], [row_2]] }
    let(:row_1) { "row_1" }
    let(:row_2) { "row_2" }
    let(:object_1) { double(:object_1) }
    let(:object_2) { double(:object_2) }
    before do
      allow(file).to receive(:read)
      allow(CSV).to receive(:parse).and_return(csv_read)
      allow(Analysis).to receive(:set_object).with(["header_"], [row_1]).and_return(object_1)
      allow(Analysis).to receive(:set_object).with(["header_"], [row_2]).and_return(object_2)
    end
    it { expect(subject).to eq [object_1, object_2] }
  end

  describe ".set_object" do
    subject { Analysis.set_object(methods, data_array) }
    let(:methods) { ["id", "name", "description", "specimen_id", "technique_id", "device_id", "operator", row_name] }
    let(:data_array) { [id, name, description, specimen_id, technique_id, device_id, operator, data] }
    let(:id) { "1" }
    let(:name) { "分析名" }
    let(:description) { "説明" }
    let(:specimen_id) { "2" }
    let(:technique_id) { "3" }
    let(:device_id) { "4" }
    let(:operator) { "オペレータ" }
    let(:nickname) {"Chem"}
    let(:row_name) {"#{nickname}"}
    let(:data) {"1"}
    let(:measurement_item) { FactoryGirl.create(:measurement_item, nickname: nickname, unit_id: unit_1.id) }
    let(:unit_1) { FactoryGirl.create(:unit, name: "parts_per_gram") }
    let(:unit_2) { FactoryGirl.create(:unit, name: "parts") }
    before do
      measurement_item
      unit_2
    end
    it { expect(subject.class).to eq Analysis }
    it do
      expect(subject.id).to eq(id.to_i)
      expect(subject.name).to eq name
      expect(subject.description).to eq description
      expect(subject.specimen_id).to eq(specimen_id.to_i)
      expect(subject.technique_id).to eq(technique_id.to_i)
      expect(subject.device_id).to eq(device_id.to_i)
      expect(subject.operator).to eq operator
      expect(subject.chemistries[0].measurement_item_id).to eq measurement_item.id
      expect(subject.chemistries[0].value).to eq data.to_f
      expect(subject.chemistries[0].unit_id).to eq unit_1.id 
    end
    context "chemistry_with_unit" do
      let(:row_name) {"#{nickname}_in_#{unit_2.name}"}
      it do
        expect(subject.chemistries[0].measurement_item_id).to eq measurement_item.id
        expect(subject.chemistries[0].value).to eq data.to_f
        expect(subject.chemistries[0].unit_id).to eq unit_2.id
      end
    end 
  end

  describe "#set_chemistry" do
    subject { analysis.set_chemistry(nickname, unit_name, data) }
    let(:analysis) { FactoryGirl.create(:analysis) }
    let(:nickname) { "nickname" }
    let(:unit_name) { nil }
    let(:data) { " 10 " }
    let(:measurement_item) { FactoryGirl.create(:measurement_item, nickname: nickname, unit_id: unit_1.id) }
    let(:unit_1) { FactoryGirl.create(:unit, name: "parts_per_gram") }
    let(:unit_2) { FactoryGirl.create(:unit, name: "parts") }
    before do
      measurement_item
      unit_2
    end
    context "data is a String" do
      context "unit_name is nil" do
        context "measurement_item.unit is present" do
          it do
            expect(subject.class).to eq Chemistry
            expect(subject.persisted?).to eq false
            expect(subject.unit_id).to eq(unit_1.id)
          end
        end
        context "measurement_item.unit is blank" do
          let(:measurement_item) { FactoryGirl.create(:measurement_item, nickname: nickname, unit_id: nil) }
          it do
            expect(subject.class).to eq Chemistry
            expect(subject.persisted?).to eq false
            expect(subject.unit_id).to eq(unit_2.id)
          end
        end
      end
      context "unit_name is not nil" do
        let(:unit_name) { unit_1.name }
        it do
          expect(subject.class).to eq Chemistry
          expect(subject.persisted?).to eq false
          expect(subject.unit_id).to eq(unit_1.id)
        end
      end
    end
    context "data is not String" do
      context "data is nil" do
        let(:data) { nil }
        it { expect(subject).to eq nil }
      end
      context "data is not nil" do
        let(:data) { 10 }
        context "unit_name is nil" do
          context "measurement_item.unit is present" do
            it do
              expect(subject.class).to eq Chemistry
              expect(subject.persisted?).to eq false
              expect(subject.unit_id).to eq(unit_1.id)
            end
          end
          context "measurement_item.unit is blank" do
            let(:measurement_item) { FactoryGirl.create(:measurement_item, nickname: nickname, unit_id: nil) }
            it do
              expect(subject.class).to eq Chemistry
              expect(subject.persisted?).to eq false
              expect(subject.unit_id).to eq(unit_2.id)
            end
          end
        end
        context "unit_name is not nil" do
          let(:unit_name) { unit_1.name }
          it do
            expect(subject.class).to eq Chemistry
            expect(subject.persisted?).to eq false
            expect(subject.unit_id).to eq(unit_1.id)
          end
        end
      end
    end
  end

  describe "#set_uncertainty" do
    subject { analysis.set_uncertainty(nickname, data) }
    let(:analysis) { FactoryGirl.create(:analysis) }
    let(:nickname) { "nickname" }
    let(:data) { " 10 " }
    let(:chemistry){ FactoryGirl.create(:chemistry, analysis_id: analysis.id, measurement_item_id: measurement_item.id, uncertainty: nil) }
    let(:measurement_item) { FactoryGirl.create(:measurement_item, nickname: nickname) }
    context "analysis associated chemistry" do
      before { chemistry }
      context "data is a String" do
        it { expect(subject).to eq(data.strip) }
      end
      context "data is not String" do
        let(:data) { 10 }
        it { expect(subject).to eq(data) }
      end
    end
    context "analysis not associate chemistry" do
      it { expect(subject).to eq nil }
    end
  end

  describe "#get_chemistry_value" do
    subject { analysis.get_chemistry_value(nickname, unit_name) }
    let(:analysis) { FactoryGirl.create(:analysis) }
    let(:nickname) { "nickname" }
    let(:unit_name) { "gram_per_gram" }
    let(:chemistry){ FactoryGirl.create(:chemistry, analysis_id: analysis.id, measurement_item_id: measurement_item.id, unit_id: unit.id) }
    let(:measurement_item) { FactoryGirl.create(:measurement_item, nickname: nickname) }
    let(:unit) { FactoryGirl.create(:unit, name: unit_name, conversion: 1) }
    before do
      Alchemist.setup
      Alchemist.register(:mass, unit.name.to_sym, 1.to_d / unit.conversion)
    end
    context "analysis associated chemistry" do
      before { chemistry }
      context "chemistry.unit is exist" do
        it { expect(subject).to eq(chemistry.value) }
      end
      context "chemistry.unit is not exist" do
        # chemistry.unit_id は必須であるためテストできない
      end
    end
    context "analysis not associate chemistry" do
      it { expect(subject).to eq nil }
    end
  end

  describe "#associate_chemistry_by_item_nickname" do
    subject { analysis.associate_chemistry_by_item_nickname(nickname) }
    let(:analysis) { FactoryGirl.create(:analysis) }
    let(:nickname) { "nickname" }
    let(:chemistry){ FactoryGirl.create(:chemistry, analysis_id: analysis.id, measurement_item_id: measurement_item.id) }
    let(:measurement_item) { FactoryGirl.create(:measurement_item, nickname: nickname) }
    before { chemistry }
    context "nickname equal chemistry.measurement_item.nickname" do
      it { expect(subject).to eq chemistry }
    end
    context "nickname is not equal chemistry.measurement_item.nickname" do
      let(:measurement_item) { FactoryGirl.create(:measurement_item, nickname: "foo") }
      it { expect(subject).to eq nil }
    end
  end

  describe "#to_castemls" do
    subject { Analysis.to_castemls(objs) }
    let(:spot){FactoryGirl.create(:spot)}
    let(:attachment_file){FactoryGirl.create(:attachment_file)}
    let(:chemistry){FactoryGirl.create(:chemistry)}
    let(:obj) { FactoryGirl.create(:analysis) }
    let(:obj2) { FactoryGirl.create(:analysis) }
    let(:objs){ [obj,obj2]}
    before do
      attachment_file.spots << spot
      obj.attachment_files << attachment_file
      obj.chemistries << chemistry
    end
    it {expect(subject).to be_present}
  end

  describe "#to_pml" do
    let(:box){ FactoryGirl.create(:box)}
    let(:specimen){ FactoryGirl.create(:specimen, box_id: box.id)}
    let(:spot){FactoryGirl.create(:spot, target_uid: obj.global_id)}
    let(:attachment_file){FactoryGirl.create(:attachment_file)}
    let(:chemistry){FactoryGirl.create(:chemistry)}
    let(:obj) { FactoryGirl.create(:analysis) }
    let(:obj2) { FactoryGirl.create(:analysis) }
    let(:obj3) { FactoryGirl.create(:analysis, specimen_id: specimen.id) }
    let(:objs){ [obj,obj2, specimen]}
    let(:objs2){ [obj,obj2,box]}
    before do
      attachment_file.spots << spot
      obj.attachment_files << attachment_file
      obj.chemistries << chemistry
      obj3
    end
    it { expect(obj.to_pml).to be_present }
    it { expect(objs.to_pml).to be_eql([obj, obj2, obj3].to_pml) }
    it { expect(objs2.to_pml).to be_eql([obj, obj2, obj3].to_pml) }
    context "with place" do
      let(:place){ FactoryGirl.create(:place)}
      let(:specimen){ FactoryGirl.create(:specimen, box_id: box.id, place_id: place.id)}

      before do
        #puts obj.to_pml
      end
      it { expect(obj.to_pml).to match(/place/)}
    end
  end

  describe "#to_pmlame" do
    subject { analysis.to_pmlame({duplicate_names: duplicate_names}) }
    let(:analysis) { FactoryGirl.create(:analysis,  name: "analysis_name_1") }
    let(:chemistry_1) { FactoryGirl.create(:chemistry) }
    let(:chemistry_2) { FactoryGirl.create(:chemistry) }
    let(:measurement_item_1) { FactoryGirl.create(:measurement_item, nickname: nickname_1) }
    let(:measurement_item_2) { FactoryGirl.create(:measurement_item, nickname: nickname_2) }
    let(:duplicate_names) { [] }
    let(:nickname_1) { "Si" }
    let(:nickname_2) { "SiO2" }
    before do
      chemistry_1.measurement_item = measurement_item_1
      chemistry_2.measurement_item = measurement_item_2
      analysis.chemistries << chemistry_1
      analysis.chemistries << chemistry_2
    end

    context "when it exists duplicate element names,", :current => true do
      let(:duplicate_names) { ["analysis_name_1"] }
      it "elementに<stone XXXX> が付加されてること" do
        allow(chemistry_1).to receive(:measured_value).and_return(nil)
        allow(chemistry_1).to receive(:measured_uncertainty).and_return(nil)
        allow(chemistry_2).to receive(:measured_value).and_return(10)
        allow(chemistry_2).to receive(:measured_uncertainty).and_return(0.1)
        global_id = analysis.specimen.global_id
        element_name = "analysis_name_1 <stone #{global_id}>"
        result = {
          element: element_name, sample_id: global_id,
          lat: analysis.specimen.place.latitude, lng: analysis.specimen.place.longitude,
          "#{nickname_1}" => nil, "#{nickname_1}_error" => nil,
          "#{nickname_2}" => 10, "#{nickname_2}_error" => 0.1
        }
        expect(subject).to eq(result)
      end
    end
    context "when it does not exists duplicate element names," do
      let(:duplicate_names) { ["analysis_name_2"] }
      it "elementに<stone XXXX> が付加されていないこと" do
        allow(chemistry_1).to receive(:measured_value).and_return(nil)
        allow(chemistry_1).to receive(:measured_uncertainty).and_return(nil)
        allow(chemistry_2).to receive(:measured_value).and_return(10)
        allow(chemistry_2).to receive(:measured_uncertainty).and_return(0.1)
        element_name = "analysis_name_1"
        global_id = analysis.specimen.global_id
        result = {
          element: element_name, sample_id: global_id,
          lat: analysis.specimen.place.latitude, lng: analysis.specimen.place.longitude,
          "#{nickname_1}" => nil, "#{nickname_1}_error" => nil,
          "#{nickname_2}" => 10, "#{nickname_2}_error" => 0.1
        }
        expect(subject).to eq(result)
      end
    end
    context "when it exists chemistry," do
      it "return element info and measured values." do
        allow(chemistry_1).to receive(:measured_value).and_return(nil)
        allow(chemistry_1).to receive(:measured_uncertainty).and_return(nil)
        allow(chemistry_2).to receive(:measured_value).and_return(10)
        allow(chemistry_2).to receive(:measured_uncertainty).and_return(0.1)
        element_name = "analysis_name_1"
        global_id = analysis.specimen.global_id
        result = {
          element: element_name, sample_id: global_id,
          lat: analysis.specimen.place.latitude, lng: analysis.specimen.place.longitude,
          "#{nickname_1}" => nil, "#{nickname_1}_error" => nil,
          "#{nickname_2}" => 10, "#{nickname_2}_error" => 0.1
        }
        expect(subject).to eq(result)
      end
    end
    context "when it does not exists duplicate element names," do
      let(:duplicate_names) { ["analysis_name_2"] }
      it "elementに<stone XXXX> が付加されていないこと" do
        allow(chemistry_1).to receive(:measured_value).and_return(nil)
        allow(chemistry_1).to receive(:measured_uncertainty).and_return(nil)
        allow(chemistry_2).to receive(:measured_value).and_return(10)
        allow(chemistry_2).to receive(:measured_uncertainty).and_return(0.1)
        element_name = "analysis_name_1"
        global_id = analysis.specimen.global_id
        result = {
          element: element_name, sample_id: global_id,
          lat: analysis.specimen.place.latitude, lng: analysis.specimen.place.longitude,
          "#{nickname_1}" => nil, "#{nickname_1}_error" => nil,
          "#{nickname_2}" => 10, "#{nickname_2}_error" => 0.1
        }
        expect(subject).to eq(result)
      end
    end
    context "when it exists chemistry," do
      it "return element info and measured values." do
        allow(chemistry_1).to receive(:measured_value).and_return(nil)
        allow(chemistry_1).to receive(:measured_uncertainty).and_return(nil)
        allow(chemistry_2).to receive(:measured_value).and_return(10)
        allow(chemistry_2).to receive(:measured_uncertainty).and_return(0.1)
        element_name = "analysis_name_1"
        global_id = analysis.specimen.global_id
        result = {
          element: element_name, sample_id: global_id,
          lat: analysis.specimen.place.latitude, lng: analysis.specimen.place.longitude,
          "#{nickname_1}" => nil, "#{nickname_1}_error" => nil,
          "#{nickname_2}" => 10, "#{nickname_2}_error" => 0.1
        }
        expect(subject).to eq(result)
      end
    end
    context "when it does not exists chemistry," do
      before do
        analysis.chemistries = []
      end
      it "return only element info." do
        global_id = analysis.specimen.global_id
        allow(chemistry_1).to receive(:measured_value).and_return(20)
        allow(chemistry_1).to receive(:measured_uncertainty).and_return(0.2)
        allow(chemistry_2).to receive(:measured_value).and_return(10)
        allow(chemistry_2).to receive(:measured_uncertainty).and_return(0.1)
        element_name = "analysis_name_1"
        expect(subject).to eq({element: element_name, sample_id: global_id, lat: analysis.specimen.place.latitude, lng: analysis.specimen.place.longitude})
      end
    end
    context "when it does not exists specimen," do
      before do
        analysis.specimen = nil
      end
      it "return element info and measured values without sample_id." do
        allow(chemistry_1).to receive(:measured_value).and_return(20)
        allow(chemistry_1).to receive(:measured_uncertainty).and_return(0.2)
        allow(chemistry_2).to receive(:measured_value).and_return(10)
        allow(chemistry_2).to receive(:measured_uncertainty).and_return(0.1)
        element_name = "analysis_name_1"
        result = {
          element: element_name, sample_id: nil,
          lat: nil, lng: nil,
          "#{nickname_1}" => 20, "#{nickname_1}_error" => 0.2,
          "#{nickname_2}" => 10, "#{nickname_2}_error" => 0.1
        }
        expect(subject).to eq(result)
      end
    end
  end

  describe ".get_spot" do
    subject { obj.get_spot }
    let(:user){FactoryGirl.create(:user)}
    let(:obj) {FactoryGirl.create(:analysis) }
    let(:spot1){FactoryGirl.create(:spot,target_uid: global_id)}
    let(:spot2){FactoryGirl.create(:spot,target_uid: global_id)}
    before{User.current = user}
    context "no spots" do
      let(:global_id){"xxx"}
      before do
        obj
        spot1
      end
      it{expect(subject).to be_nil}
    end
    context "1 spot exists" do
      let(:global_id){obj.global_id}
      before do
        obj
        spot1
      end
      it{expect(subject).to eq spot1}
    end
    context "2 spot exists" do
      let(:global_id){obj.global_id}
      before do
        obj
        spot1
        spot2
      end
      it{expect(subject).to eq spot1}
    end
  end

  describe "publish!" do
    subject { analysis.publish! }
    let(:analysis) { FactoryGirl.create(:analysis) }
    before do
      analysis
    end
    it { expect{subject}.not_to raise_error }
  end

  describe "#update_table_analyses" do
    subject { analysis.send(:update_table_analyses) }
    let(:analysis) { FactoryGirl.create(:analysis, name: "分析１", specimen: specimen_1) }
    let(:specimen_1) { FactoryGirl.create(:specimen, name: "ストーン１") }
    let(:specimen_2) { FactoryGirl.create(:specimen, name: "ストーン２") }
    context "not change associated specimen" do
      it { expect{ subject }.not_to change(TableAnalysis, :count) }
    end
    context "change associated specimen" do
      before { analysis.specimen_id = specimen_2.id }
      context "analysis not linked table_specimen" do
        it { expect{ subject }.not_to change(TableAnalysis, :count) }
      end
      context "analysis linked table_specimen" do
        before do
          table_specimen
          other_table_specimen
          table_analysis
        end
        let(:table_specimen) { FactoryGirl.create(:table_specimen, specimen: specimen_2) }
        let(:other_table_specimen) { FactoryGirl.create(:table_specimen, specimen: specimen_3) }
        let(:specimen_3) { FactoryGirl.create(:specimen, name: "ストーン３") }
        let(:table_analysis) { FactoryGirl.create(:table_analysis, table_id: table_specimen.table_id, specimen_id: table_specimen.specimen_id, priority: priority) }
        let(:priority) { 1 }
        it { expect{ subject }.to change(TableAnalysis, :count).by(1) }
        it do
          subject
          table_analysis = TableAnalysis.last
          expect(table_analysis.table_id).to eq(table_specimen.table_id)
          expect(table_analysis.specimen_id).to eq(table_specimen.specimen_id)
          expect(table_analysis.analysis_id).to eq(analysis.id)
          expect(table_analysis.priority).to eq(priority + 1)
        end
      end
    end
  end

  describe "#pml_elements" do
    subject { obj.pml_elements }
    let(:obj) { FactoryGirl.create(:analysis)}
    it { expect(subject).to match_array([obj]) }
  end

end
