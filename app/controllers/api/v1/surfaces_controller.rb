class Api::V1::SurfacesController < Api::ApplicationController
  before_action :find_resource, except: [:index, :create]
  load_and_authorize_resource

  def index
    @search = Surface.readables(current_user).ransack(params[:q])
    @search.sorts = ["globe DESC", "updated_at DESC"] if @search.sorts.empty?
    @surfaces = @search.result.page(params[:page]).per(params[:per_page])
    render json: Rails.cache.fetch(@surfaces){ @surfaces.to_json }
  end

  def show
    render json: @surface
  end

  def create
    @surface = Surface.new(surface_params)
    @surface.save
    render json: @surface
  end

  def update
    @surface.update(surface_params)
    rendier json: @surface
  end
  
  def destroy
    @surface.destroy
    respond_with @surface
  end

  private

  def surface_params
    params.require(:surface).permit(
      :name,
      :length,
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
        :lost
      ], 
      surface_images_attributes: [
        :id,
        :surface_layer_id
      ]
    )
  end

  def find_resource
    @surface = Surface.includes(:record_property, 
      {surface_layers: [:surface, {surface_images: [:image, :surface]}]}, 
      {surface_images: [:surface, {image: [:record_property, :spots]}]}, 
      {not_belongs_to_layer_surface_images: [:image, :surface]}, 
      {wall_surface_images: [:image, :surface]}).find(params[:id]).decorate
    #@surface_layers = SurfaceLayer.where(surface_id: params[:id]).includes({surface_images: [:image,:surface]})
    @image = @surface.first_image
    bibs_per_page = 5
    specimens_per_page = 5
    @bibs = Bib.where(id: Referring.where(referable_type: "Surface").where(referable_id: @surface.id).pluck(:bib_id)).order("updated_at DESC").page(params[:page]).per(bibs_per_page)
    @specimens = @surface.specimens.order("updated_at DESC").page(params[:page]).per(specimens_per_page)
    @spot_specimens = @surface.spot_specimens.order("specimens.updated_at DESC").page(params[:page]).per(specimens_per_page)
  end

  def find_resources
    @surfaces = SurfaceDecorator.decorate_collection(Surface.where(id: params[:ids]))
  end

end
