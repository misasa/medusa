require 'spec_helper'

describe SpotDecorator do
  let(:user){ FactoryGirl.create(:user)}
  let(:spot){FactoryGirl.create(:spot).decorate}
  before{User.current = user}

  describe ".taget_link" do
    subject{ spot.target_link }
    context "target_uid is nil" do
      before{spot.target_uid = nil}
      it {expect(subject).to eq ""}
    end
    context "target_uid is error global_id" do
      before{spot.target_uid = "aaa"}
      it {expect(subject).to eq ""}
    end
    context "target_uid is no datum  global_id" do
      let(:bib){FactoryGirl.create(:bib,name: "test bib")}
      before do
        spot.target_uid = bib.record_property.global_id
        bib.destroy
      end
      it {expect(subject).to eq ""}
    end
    context "target_uid is OK global_id" do
      let(:bib){FactoryGirl.create(:bib,name: "test bib")}
      before{spot.target_uid = bib.record_property.global_id}
      it {expect(subject).to eq "<a href=\"/bibs/#{bib.id}\">test bib</a>"}
    end
  end

end
