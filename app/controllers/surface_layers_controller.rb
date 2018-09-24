class SurfaceLayersController < ApplicationController
  respond_to :html, :xml, :json, :svg
  before_action :find_surface
  before_action :find_resource, except: [:index, :new, :create, :link_by_global_id]

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

  def move_to_top
    SurfaceLayer.transaction { @surface_layer.move_to_top }
    respond_with @surface_layer, location: adjust_url_by_requesting_tab(request.referer)
  end

  private

  def surface_layer_params
    params.require(:surface_layer).permit(
      :name,
      :opacity,
      :priority
    )
  end

  def find_surface
    @surface = Surface.find(params[:surface_id]).decorate
  end

  def find_resource
    @surface_layer = @surface.surface_layers.find(params[:id]).decorate
  end
end
