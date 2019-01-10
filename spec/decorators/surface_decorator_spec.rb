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

end
