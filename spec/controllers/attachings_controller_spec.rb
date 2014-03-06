require 'spec_helper'

describe AttachingsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:place1) { FactoryGirl.create(:place,name: "place1") }
  let(:place2) { FactoryGirl.create(:place,name: "place2") }
  let(:attachment_file1) { FactoryGirl.create(:attachment_file,name: "attachment_file1") }
  let(:attachment_file2) { FactoryGirl.create(:attachment_file,name: "attachment_file2") }
  let(:attaching1) { FactoryGirl.create(:attaching,attachable: place1,attachment_file: attachment_file1) }
  let(:attaching2) { FactoryGirl.create(:attaching,attachable: place1,attachment_file: attachment_file2) }
  let(:attaching3) { FactoryGirl.create(:attaching,attachable: place2,attachment_file: attachment_file1) }
  before do
    sign_in user 
    attaching1
    attaching2
    attaching3
  end
    

  describe "POST move_to_top" do
    context "not count change" do
      it { expect { post :move_to_top, id: attaching2.id  }.to change(Attaching, :count).by(0) }
    end
    
    context " move to top" do
      before do
        post :move_to_top, id: attaching2.id
        attaching1.reload
        attaching2.reload
      end
      it { expect(attaching1.attachable_id).to eq attaching2.attachable_id}
      it { expect(attaching1.attachable_type).to eq attaching2.attachable_type}
      it { expect(attaching1.position).to eq 2}
      it { expect(attaching2.position).to eq 1}
      it { expect(attaching3.position).to eq 1}
    end
  end

  describe "DELETE destroy" do
    context "count 1 gain " do
      it { expect { delete :destroy,id: attaching1.id }.to change(Attaching, :count).by(-1) }
    end
    context "delete " do
      before { delete :destroy,id: attaching1.id }
      it {expect( Attaching.count ).to be 2}
      it {expect( Attaching.exists?(attaching1.id)).to be_falsey}
      it {expect( Attaching.exists?(attaching2.id)).to be_truthy} 
      it {expect( Attaching.exists?(attaching3.id)).to be_truthy}
    end
  end
end
