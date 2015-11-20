class MeasurementItemsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = MeasurementItem.includes(:measurement_categories, :chemistries).search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @measurement_items = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @measurement_items
  end

  def show
    respond_with @measurement_item
  end

  def edit
    respond_with @measurement_item
  end

  def create
    @measurement_item = MeasurementItem.new(measurement_item_params)
    @measurement_item.save
    respond_with @measurement_item
  end

  def update
    @measurement_item.update_attributes(measurement_item_params)
    respond_with(@measurement_item, location: measurement_items_path)

  end

  def destroy
    @measurement_item.destroy
    respond_with @measurement_item
  end

  private

  def measurement_item_params
    params.require(:measurement_item).permit(
      :nickname,
      :description,
      :display_in_html,
      :display_in_tex,
      :unit_id,
      measurement_category_ids: []
    )
  end

  def find_resource
    @measurement_item = MeasurementItem.find(params[:id])
  end

end
