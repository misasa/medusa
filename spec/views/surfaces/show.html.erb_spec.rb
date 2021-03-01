require 'spec_helper'

describe "surfaces/show.html.erb" do
  let(:user) { FactoryBot.create(:user) }
  let(:obj_1){ FactoryBot.create(:surface, name: 'hoge')  }
  let(:specimen_1){ FactoryBot.create(:specimen, name: 'sample-1')  }
  let(:specimen_2){ FactoryBot.create(:specimen, name: 'sample-2')  }
  let(:bib_1){ FactoryBot.create(:bib, name: 'bib-1')  }
  let(:bib_2){ FactoryBot.create(:bib, name: 'bib-2')  }

  before do
    assign(:surface, obj_1.decorate)
    assign(:alias_specimen, "stone")
    assign(:specimens, Kaminari.paginate_array([
      specimen_1,
      specimen_2
    ]).page(1))    
    assign(:bibs, Kaminari.paginate_array([
      bib_1,
      bib_2
    ]).page(1))    

    #assign(:current_user, user)
    assign(:records_search, RecordProperty.search)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
    controller.stub(:current_user){ user }
  end
  context "without image" do
    it 'works' do
      render
      expect(rendered).to match /hoge/
    end
  end
  context "with image" do
    let(:image_1) { FactoryBot.create(:attachment_file, :name => 'fuga', :affine_matrix => nil) }
    before do
      obj_1.images << image_1
    end
    it 'works' do
      render
      expect(rendered).to match /hoge/
    end
  end
end
