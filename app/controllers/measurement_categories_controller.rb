class MeasurementCategoriesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :duplicate, :update, :destroy]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = MeasurementCategory.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @measurement_categories = @search.result.page(params[:page]).per(params[:per_page])
  end

  def show
    respond_with @measurement_category
  end

  def edit
    respond_with @measurement_category
  end

  def create
    @measurement_category = MeasurementCategory.new(measurement_category_params)
    @measurement_category.save
    respond_with @measurement_category
  end

  def duplicate
    measuerement_category_orgin = @measurement_category
    @measurement_category = measuerement_category_orgin.dup
    @measurement_category.name += " duplicate"
    @measurement_category.save
    measuerement_category_orgin.measurement_items.each do |measurement_item|
      @measurement_category.measurement_items << measurement_item
    end
    respond_with @measurement_category do |format|
      format.html {render :edit}
    end
  end

  def update
    @measurement_category.update_attributes(measurement_category_params)
    respond_with(@measurement_category, location: measurement_categories_path)
  end

  def destroy
    @measurement_category.destroy
    respond_with @measurement_category
  end

  private

  def measurement_category_params
    params.require(:measurement_category).permit(
      :name,
      :description,
      :unit_id
    )
  end

  def find_resource
    @measurement_category = MeasurementCategory.find(params[:id])
  end

end
