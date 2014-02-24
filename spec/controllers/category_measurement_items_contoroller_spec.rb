require 'spec_helper'

describe CategoryMeasurementItemsController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "POST move_to_top" do
    let(:category_measurement_item) { FactoryGirl.create(:category_measurement_item) }
    before{category_measurement_item}
    it { expect { post :move_to_top, id: category_measurement_item.id  }.to change(CategoryMeasurementItem, :count).by(0) }
    context "" do
      before {post :move_to_top, id: category_measurement_item.id}
      it { expect(assigns(:category_measurement_item).position).to eq 1}
      it { expect(response).to redirect_to(edit_measurement_category_path(category_measurement_item.measurement_category))}
    end
  end

  describe "DELETE destroy" do
    let(:category_measurement_item) { FactoryGirl.create(:category_measurement_item) }
    let(:measurement_category){category_measurement_item.measurement_category}
    before do
      category_measurement_item
      measurement_category
    end
    it { expect { delete :destroy,id: category_measurement_item.id }.to change(CategoryMeasurementItem, :count).by(-1) }
    context "" do
      before {post :move_to_top, id: category_measurement_item.id}
      it { expect(response).to redirect_to(edit_measurement_category_path(measurement_category))}
    end
  end
end
