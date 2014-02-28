class UnitsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create]
  load_and_authorize_resource
  layout "admin"
  
  def index
    @search = Unit.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @units = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @units
  end
  
  def show
    respond_with @unit
  end
  
  def edit
    respond_with @unit
  end
  
  def create
    @unit = Unit.new(unit_params)
    @unit.save
    respond_with(@unit, location: units_path)
  end
  
  def update
    @unit.update_attributes(unit_params)
    respond_with(@unit, location: units_path)
  end
  
  private
  
  def unit_params
    params.require(:unit).permit(:name)
  end
  
  def find_resource
    @unit = Unit.find(params[:id])
  end
  
end