class NestedResources::ChemistriesController < ApplicationController

  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :multiple_new, :multiple_create, :create]
  before_action :find_resources, only: [:multiple_new, :multiple_create, :create, :update, :destroy]
  load_and_authorize_resource

  def index
    @chemistries = Analysis.find(params[:analysis_id]).chemistries
    respond_with @chemistries
  end

  def multiple_new
    @chemistries = []
    MeasurementItem.joins(:category_measurement_items,:measurement_categories).where(measurement_categories: {id: params[:measurement_category_id]}).order("category_measurement_items.position").each do |measurement_item|
      @chemistries << Chemistry.new(analysis_id: @parent.id, measurement_item_id: measurement_item.id,unit_id: measurement_item.unit_id)
    end
    @chemistries.uniq!
    respond_with @chemistries
  end

  def multiple_create
    @chemistries = []
    chemistries_params.each do |param|
      @chemistries << Chemistry.new(param)
    end
    @parent.chemistries << @chemistries
    respond_with @chemistries, location: analysis_path(@parent)
  end

  def create
    @chemistry = Chemistry.new(chemistry_params)
    @parent.chemistries << @chemistry
    respond_with @chemistry, location: adjust_url_by_requesting_tab(request.referer), action: "error"
  end

  def update
    @chemistry = Chemistry.find(params[:id])
    @parent.chemistries << @chemistry
    respond_with @chemistry, location: adjust_url_by_requesting_tab(request.referer)
  end

  def destroy
    @chemistry.destroy
    @parent.chemistries.delete(@chemistry)
    respond_with @chemistry, location: adjust_url_by_requesting_tab(request.referer)
  end

  private

  def chemistries_params
#TODO permitのパラメータチェックの仕方を調べる
    params.require(:chemistries)

#    params.require(:chemistries).permit([
#        :measurement_item_id,
#        :value,
#        :uncertainty,
#        :unit_id
#      ]
#    )
  end

  def chemistry_params
    params.require(:chemistry).permit(
        :measurement_item_id,
        :info,
        :value,
        :label,
        :description,
        :uncertainty,
        :unit_id,
        record_property_attributes: [
          :global_id,
          :user_id,
          :group_id,
          :owner_readable,
          :owner_writable,
          :group_readable,
          :group_writable,
          :guest_readable,
          :guest_writable,
          :published,
          :published_at
        ]
    )
   end

  def find_resource
    @chemistry = Chemistry.find(params[:id]).decorate
  end

  def find_resources
    @parent = Analysis.find(params[:analysis_id])
  end

end
