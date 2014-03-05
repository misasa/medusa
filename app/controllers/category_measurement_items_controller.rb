class CategoryMeasurementItemsController < ApplicationController
  load_and_authorize_resource

  def move_to_top
    @category_measurement_item.move_to_top
    redirect_to edit_measurement_category_path(@category_measurement_item.measurement_category) 
  end

  def destroy
    measurement_category = @category_measurement_item.measurement_category
    @category_measurement_item.destroy
    redirect_to edit_measurement_category_path(measurement_category) 
  end

end
