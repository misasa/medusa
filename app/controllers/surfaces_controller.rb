class SurfacesController < ApplicationController
  respond_to :html, :xml, :json, :svg
  before_action :find_resource, except: [:index, :create, :bundle_edit, :bundle_update]
  before_action :find_resources, only: [:bundle_edit, :bundle_update]
  load_and_authorize_resource

  def index
    @search = Surface.readables(current_user).search(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @surfaces = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @surfaces
  end

  def show
    respond_with @surface, layout: !request.xhr?  	
  end

  def edit
    respond_with @surface, layout: !request.xhr?
  end

  def create
    @surface = Surface.new(surface_params)
    @surface.save
    respond_with @surface
  end

  def update
    @surface.update_attributes(surface_params)
    respond_with @surface
  end
  
  def destroy
    @surface.destroy
    respond_with @surface
  end

  def picture
    respond_with @surface, layout: !request.xhr?
  end
  
  def property
    respond_with @surface, layout: !request.xhr?
  end

  def bundle_edit
    respond_with @surfaces
  end

  def bundle_update
    @surfaces.each { |surface| surface.update_attributes(surface_params.only_presence) }
    render :bundle_edit
  end
  private

  def surface_params
    params.require(:surface).permit(
      :name,
      record_property_attributes: [
        :global_id,
        :user_id,
        :group_id,
        :owner_readable,
        :owner_writable,
        :group_readable,
        :group_writable,
        :guest_readable,
        :guest_writable
      ]
    )
  end

  def find_resource
    @surface = Surface.find(params[:id]).decorate
  end

  def find_resources
    @surfaces = Surface.where(id: params[:ids])
  end

end
