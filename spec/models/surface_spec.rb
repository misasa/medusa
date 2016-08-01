require 'spec_helper'

describe Surface do
  describe "validates" do
    describe "name" do
      let(:obj) { FactoryGirl.build(:surface, name: name) }
      context "is presence" do
        let(:name) { "surface-1" }
        it { expect(obj).to be_valid }
      end
      context "is blank" do
        let(:name) { "" }
        it { expect(obj).not_to be_valid }
      end
      describe "length" do
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
  end

  describe "prop" do
  	let(:obj){ FactoryGirl.create(:surface) }
  	it { expect(obj.global_id).not_to be_nil }
  end

  describe "images <<" do
    subject { obj.images << image }
  	let(:obj){ FactoryGirl.create(:surface) }
    let(:image){ FactoryGirl.create(:attachment_file, data_content_type: data_content_type)}
    let(:data_content_type) { "image/jpeg" }
    before do
    	obj
    	image
    end
    context "image file" do
      let(:data_content_type) { "image/jpeg" }
      before { subject }
      it { expect(obj.images.exists?(id: image.id)).to eq true}
    end

    context "not image file" do
      let(:data_content_type) { "application/pdf" }
      it { expect{subject}.to raise_error(ActiveRecord::RecordInvalid)}
    end
  end


end
