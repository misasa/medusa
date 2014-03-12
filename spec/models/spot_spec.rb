require "spec_helper"

describe Spot do
  let(:user){FactoryGirl.create(:user)}
  before{User.current = user}

  describe ".generate_name" do
    subject{ spot.name }
    before{spot}
    context "name is not blank" do
      let(:spot){FactoryGirl.create(:spot,name: "aaaa")}
      it {expect(subject).to eq "aaaa"}
    end
    context "targe_uid is blank" do
      let(:spot){FactoryGirl.create(:spot,name: nil,target_uid: nil)}
      it {expect(subject).to eq "untitled point 1"}
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
      it {expect(subject).to eq bib.name}
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
      it {expect(subject).to eq 2.34}
    end
  end

end
