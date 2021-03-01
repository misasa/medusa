require 'spec_helper'

describe CategoryMeasurementItemsController do
  let(:user) { FactoryBot.create(:user) }
  before { sign_in user }

  describe "POST move_to_top" do
    let(:category_measurement_item) { FactoryBot.create(:category_measurement_item) }
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      category_measurement_item
    end
    it { expect { post :move_to_top, params: { id: category_measurement_item.id  }}.to change(CategoryMeasurementItem, :count).by(0) }
    context "execute" do
      before {post :move_to_top, params: { id: category_measurement_item.id }}
      it { expect(assigns(:category_measurement_item).position).to eq 1}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end

  describe "DELETE destroy" do
    let(:category_measurement_item) { FactoryBot.create(:category_measurement_item) }
    let(:measurement_category){category_measurement_item.measurement_category}
    before do
      request.env["HTTP_REFERER"]  = "where_i_came_from"
      category_measurement_item
      measurement_category
    end
    it { expect { delete :destroy, params: { id: category_measurement_item.id }}.to change(CategoryMeasurementItem, :count).by(-1) }
    context "execute" do
      before {delete :destroy, params: { id: category_measurement_item.id }}
      it { expect(response).to redirect_to request.env["HTTP_REFERER"]}
    end
  end
end
