class SurfacesController < ApplicationController
  respond_to :html, :xml, :json, :svg
  before_action :find_resource, except: [:index, :create, :bundle_edit, :bundle_update, :family]
  before_action :find_resources, only: [:bundle_edit, :bundle_update]
  load_and_authorize_resource

  def index
    @search = Surface.readables(current_user).search(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @surfaces = SurfaceDecorator.decorate_collection(@search.result)
    respond_with @surfaces do |format|
      format.html
      format.json { render json: Rails.cache.fetch(@surfaces){ @surfaces.to_json }}
      format.xml
    end
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

  def family
    @surface = Surface.preload(images: :spots).find(params[:id]).decorate
    respond_with @surface, layout: !request.xhr?
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

  def map
    respond_with @surface, layout: !request.xhr?
  end

  private

  def surface_params
    params.require(:surface).permit(
      :name,
      record_property_attributes: [
        :id,
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
        :lost
      ],
      surface_images_attributes: [
        :id,
        :surface_layer_id
      ]
    )
  end

  def find_resource
    @surface = Surface.find(params[:id]).decorate
    @image = @surface.first_image
  end

  def find_resources
    @surfaces = SurfaceDecorator.decorate_collection(Surface.where(id: params[:ids]))
  end

end
