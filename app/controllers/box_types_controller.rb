class BoxTypesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin"

  def index
    @box_types = BoxType.all
    respond_with @box_types
  end

  def show
    respond_with @box_type
  end

  def new
    @box_type = BoxType.new
    respond_with @box_type
  end

  def edit
    respond_with @box_type
  end

  def create
    @box_type = BoxType.new(box_type_params)
    @box_type.save
    respond_with @box_type
  end

  def update
    @box_type.update_attributes(box_type_params)
    respond_with @box_type
  end

  def destroy
    @box_type.destroy
    respond_with @box_type
  end

  private

  def box_type_params
    params.require(:box_type).permit(
      :name,
      :description
    )
  end

  def find_resource
    @box_type = BoxType.find(params[:id])
  end

end
