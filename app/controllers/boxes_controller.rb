class BoxesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update, :destroy, :upload]
  load_and_authorize_resource

  def index
    @boxes = Box.all
    respond_with @boxes
  end

  def show
    respond_with @box
  end

  def new
    @box = Box.new
    respond_with @box
  end

  def edit
    respond_with @box
  end

  def create
    @box = Box.new(box_params)
    @box.save
    respond_with @box
  end

  def update
    @box.update_attributes(box_params)
    respond_with @box
  end

  def destroy
    @box.destroy
    respond_with @box
  end

  def upload
    @box.attachment_files << params[:media]
    @box.save
    respond_with @box
  end

  private

  def box_params
    params.require(:box).permit(
      :name,
      :parent_id,
      :position,
      :path,
      :box_type_id
    )
  end

  def find_resource
    @box = Box.find(params[:id])
  end

end
