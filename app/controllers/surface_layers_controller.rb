class SurfaceLayersController < ApplicationController
  respond_to :html, :xml, :json, :svg
  before_action :find_surface
  before_action :find_resource, except: [:index, :new, :create, :link_by_global_id]

  def map
    respond_with @surface_layer, layout: !request.xhr?
  end

  def show
    respond_with @surface_layer
  end

  def create
    @surface_layer = @surface.surface_layers.build(surface_layer_params)
    @surface_layer.save
    respond_with @surface_layer, location: adjust_url_by_requesting_tab(request.referer), action: "error"
  end

  def edit
    respond_with @surface_layer, layout: !request.xhr?
  end

  def destroy
    @surface_layer.destroy
    respond_with @surface_layer, location: adjust_url_by_requesting_tab(request.referer)
  end

  def update
    @surface_layer = SurfaceLayer.find(params[:id])
    @surface_layer.update_attributes(surface_layer_params)
    respond_with @surface_layer
  end

  def tiles
    LayerTileWorker.perform_async(@surface_layer.id)
    respond_with @surface_layer, location: adjust_url_by_requesting_tab(request.referer)
  end

  def move_to_top
    SurfaceLayer.transaction { @surface_layer.move_to_top }
    respond_with @surface_layer, location: adjust_url_by_requesting_tab(request.referer)
  end

  def move_higher
    @surface_layer.move_higher
    respond_with @surface_layer, location: adjust_url_by_requesting_tab(request.referer)
  end

  def move_to_bottom
    SurfaceLayer.transaction { @surface_layer.move_to_bottom }
    respond_with @surface_layer, location: adjust_url_by_requesting_tab(request.referer)
  end

  def move_lower
    @surface_layer.move_lower
    respond_with @surface_layer, location: adjust_url_by_requesting_tab(request.referer)
  end

  def calibrate
    respond_with @surface_layer
  end

  def check
    @surface_layer.update_attributes(visible: true)
    #respond_with @surface_layer, location: adjust_url_by_requesting_tab(request.referer)
    ret = {
      visible: @surface_layer.visible
    }
    render json: ret.to_json
  end

  def uncheck
    @surface_layer.update_attributes(visible: false)
    ret = {
      visible: @surface_layer.visible
    }
    render json: ret.to_json
    #respond_with @surface_layer, location: adjust_url_by_requesting_tab(request.referer)
  end

  def toggle_visible
    if @surface_layer.visible?
      @surface_layer.update_attributes(visible: false)
    else
      @surface_layer.update_attributes(visible: true)
    end
    ret = {
      visible: @surface_layer.reload.visible
    }
    render json: ret.to_json
#    respond_with @surface_layer, location: adjust_url_by_requesting_tab(request.referer)
  end

  private

  def surface_layer_params
    params.require(:surface_layer).permit(
      :name,
      :opacity,
      :color_scale,
      :display_min,
      :display_max,
      :max_zoom_level,
      :visible,
      :priority
    )
  end

  def find_surface
    @surface = Surface.includes(:record_property, {surface_images: :image}).find(params[:surface_id]).decorate
  end

  def find_resource
    @surface_layer = @surface.surface_layers.includes({surface: {surface_images: :image}}, {surface_images: :image}).find(params[:id]).decorate
  end
end
