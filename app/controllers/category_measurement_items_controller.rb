class CategoryMeasurementItemsController < ApplicationController
  before_action :find_resource, only: [:destroy]
  load_and_authorize_resource
  layout "admin"

  def move_to_top
    @category_measurement_item.move_to_top
    redirect_to edit_measurement_category_path(@category_measurement_item.measurement_category) 
  end

  def destroy
    measurement_category = @category_measurement_item.measurement_category
    @category_measurement_item.destroy
    redirect_to edit_measurement_category_path(measurement_category) 
  end

  private

  def find_resource
    @category_measurement_item = CategoryMeasurementItem.find(params[:id])
  end

end
