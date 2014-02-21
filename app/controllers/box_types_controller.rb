class BoxTypesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = BoxType.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @box_types = @search.result.page(params[:page]).per(params[:per_page])
  end

  def show
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
    respond_with(@box_type, location: box_types_path)
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
