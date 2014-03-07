class CategoryMeasurementItemsController < ApplicationController
  respond_to  :html, :xml, :json
  load_and_authorize_resource

  def move_to_top
    @category_measurement_item.move_to_top
    respond_with @category_measurement_item, location: request.referer
  end

  def destroy
    measurement_category = @category_measurement_item.measurement_category
    @category_measurement_item.destroy
    respond_with @category_measurement_item, location: request.referer
  end

end
