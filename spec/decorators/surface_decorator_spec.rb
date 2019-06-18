require 'spec_helper'

describe SurfaceDecorator do
  let(:surface){ FactoryGirl.create(:surface).decorate }
  describe ".url_for_tile" do
    subject { surface.url_for_tile }
    before do
      allow(Settings).to receive(:map_url).and_return(map_url)
    end
    let(:map_url){"https://dream.misasa.okayama-u.ac.jp/pub/system/maps/"}
    it { expect(subject).to eq (map_url + surface.global_id + '/') }
  end
  describe "map" do
    subject { surface.decorate.map }
    let(:surface){ FactoryGirl.create(:surface) }
    let(:left) {-3808.472}
    let(:upper) {3787.006}
    let(:right) {3851.032}
    let(:bottom) {-4007.006}
    let(:map_url){"https://dream.misasa.okayama-u.ac.jp/pub/system/maps/"}
    before do
      allow(surface).to receive(:bounds).and_return([left, upper, right, bottom])
      allow(Settings).to receive(:map_url).and_return(map_url)
    end

    it { expect(subject).to match(/div/)}    
  end
end
