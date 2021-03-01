require 'spec_helper'

describe CategoryMeasurementItem do
  describe ".move_to_top" do
      let(:measurement_category){ FactoryBot.create(:measurement_category)}
      let(:measurement_category2){ FactoryBot.create(:measurement_category)}
      let(:obj1) { FactoryBot.create(:category_measurement_item, position: 1,measurement_category: measurement_category) }
      let(:obj2) { FactoryBot.create(:category_measurement_item, position: 2,measurement_category: measurement_category) }
      let(:obj3) { FactoryBot.create(:category_measurement_item, position: 3,measurement_category: measurement_category) }
      let(:obj4) { FactoryBot.create(:category_measurement_item, position: 4,measurement_category: measurement_category) }
      let(:obj5) { FactoryBot.create(:category_measurement_item, position: 1,measurement_category: measurement_category2) }
      before do
        obj1
        obj2
        obj3
        obj4
        obj5
        obj3.move_to_top
        obj1.reload
        obj2.reload
        obj3.reload
        obj4.reload
        obj5.reload
      end
      it { expect(obj1.position).to eq 2 }
      it { expect(obj2.position).to eq 3 }
      it { expect(obj3.position).to eq 1 }
      it { expect(obj4.position).to eq 4 }
      it { expect(obj5.position).to eq 1 }
  end
end
