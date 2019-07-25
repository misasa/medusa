require 'spec_helper'

describe "surfaces/family.html.erb" do
  let(:user) { FactoryGirl.create(:user) }
  let(:obj_1){ FactoryGirl.create(:surface, name: 'hoge')  }
  before do
    assign(:surface, obj_1.decorate)
    assign(:current_user, user)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end
  context "without image" do
    it 'works' do
      render
      expect(rendered).not_to have_css('div.large-map')
    end
  end

  context "with image which is not calibrated" do
    let(:image_1) { FactoryGirl.create(:attachment_file, :name => 'fuga', :affine_matrix => nil) }
    before do
      obj_1.images << image_1
    end
    it 'works' do
      render
      expect(rendered).not_to have_css('div.large-map')
    end
  end

  context "with calibrated image and uncalibrated images" do
    let(:image_1) { FactoryGirl.create(:attachment_file, :name => 'fuga_1') }
    let(:image_2) { FactoryGirl.create(:attachment_file, :name => 'fuga_2', :affine_matrix => nil) }
    let(:image_3) { FactoryGirl.create(:attachment_file, :name => 'fuga_3', :affine_matrix => []) }

    before do
      obj_1.images << image_1
      obj_1.images << image_2
      obj_1.images << image_3
    end
    it 'works' do
      render
      expect(rendered).to have_css('div.large-map')
    end
  end

  context "with calibrated image" do
    let(:image_1) { FactoryGirl.create(:attachment_file, :name => 'fuga') }
    before do
      obj_1.images << image_1
    end
    it 'works' do
      render
      expect(rendered).to have_css('div.large-map')
    end
  end
end
