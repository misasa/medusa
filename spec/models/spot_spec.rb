require "spec_helper"

describe Spot do
  let(:user){FactoryGirl.create(:user)}
  before{User.current = user}

  describe "validates" do
    describe "spot_x" do
      let(:obj) { FactoryGirl.build(:spot, spot_x: spot_x) }
      context "is presence" do
        let(:spot_x) { "0" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:spot_x) { "" }
        it { expect(obj).not_to be_valid }
      end
    end
    describe "spot_y" do
      let(:obj) { FactoryGirl.build(:spot, spot_y: spot_y) }
      context "is presence" do
        let(:spot_y) { "0" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:spot_y) { "" }
        it { expect(obj).not_to be_valid }
      end
    end
  end

  describe ".generate_name" do
    subject{ spot.name }
    before{spot}
    context "name is not blank" do
      let(:spot){FactoryGirl.create(:spot,name: "aaaa")}
      it {expect(subject).to eq "aaaa"}
    end
    context "targe_uid is blank" do
      let(:spot){FactoryGirl.create(:spot,name: nil,target_uid: nil)}
      it {expect(subject).to eq "untitled spot 1"}
    end
    context "target_uid is error global_id" do
      let(:spot){FactoryGirl.create(:spot,name: nil,target_uid: "aaa")}
      it {expect(subject).to eq "aaa"}
    end
    context "target_uid is no datum  global_id" do
      let(:bib){FactoryGirl.create(:bib,name: "test bib")}
      let(:record_property){bib.record_property}
      let(:spot){FactoryGirl.build(:spot,name: nil,target_uid: record_property.global_id)}
      before do
        bib.destroy
        spot.save
      end
      it {expect(subject).to eq record_property.global_id}
    end
    context "target_uid is OK global_id" do
      let(:bib){FactoryGirl.create(:bib,name: "test bib")}
      let(:spot){FactoryGirl.create(:spot,name: nil,target_uid: bib.record_property.global_id)}
      it {expect(subject).to eq "spot of " + bib.name}
    end
  end

  describe ".genarate_stroke_width" do
    subject{ spot.stroke_width }
    context "stroke_width is not blank" do
      let(:spot){FactoryGirl.create(:spot,stroke_width: 9)}
      it {expect(subject).to eq 9}
    end
    context "stroke_width is not blank" do
      let(:spot){FactoryGirl.build(:spot,stroke_width: nil)}
      before do
        spot.attachment_file.original_geometry = "123x234"
        spot.save
      end
      it {expect(subject).to eq 1.17}
    end
  end

  # describe ".spot_x_from_center" do
  #   subject{obj.spot_x_from_center}
  #   let(:obj){FactoryGirl.create(:spot)}
  #   it {expect(subject).to eq -49.0}
  # end

  # describe ".spot_y_from_center" do
  #   subject{obj.spot_y_from_center}
  #   let(:obj){FactoryGirl.create(:spot)}
  #   it {expect(subject).to eq 49.0}
  # end

  describe "#ref_image_x" do
    subject { spot.ref_image_x }
    let(:spot) { FactoryGirl.build(:spot, spot_x: spot_x, attachment_file: attachment_file) }
    let(:spot_x) { 10.0 }
    let(:attachment_file) { FactoryGirl.create(:attachment_file) }
    before do
      allow(attachment_file).to receive(:length).and_return(length)
    end
    context "length is nil" do
      let(:length) { nil }
      it { expect(subject).to be_nil }
    end
    context "length is present" do
      let(:length) { 100 }
      it { expect(subject).to eq (spot_x / length * 100) }
    end
  end

  describe "#ref_image_y" do
    subject { spot.ref_image_y }
    let(:spot) { FactoryGirl.build(:spot, spot_y: spot_y, attachment_file: attachment_file) }
    let(:spot_y) { 20.0 }
    let(:attachment_file) { FactoryGirl.create(:attachment_file) }
    before do
      allow(attachment_file).to receive(:length).and_return(length)
    end
    context "length is nil" do
      let(:length) { nil }
      it { expect(subject).to be_nil }
    end
    context "length is present" do
      let(:length) { 100 }
      it { expect(subject).to eq (spot_y / length * 100) }
    end
  end

end
