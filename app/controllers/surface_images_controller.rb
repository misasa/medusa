class SurfaceImagesController < ApplicationController
  layout 'fluid'
  respond_to :html, :xml, :json, :svg
  before_action :find_surface
  before_action :find_resource, except: [:index, :new, :create, :link_by_global_id]
#  load_and_authorize_resource

  def index
    @surface_images = SurfaceImageDecorator.decorate_collection(@surface.surface_images)
    respond_with @surface_images
  end

  def show
    #@surface_image = @surface.surface_images.find_by_image_id(@image.id)
    respond_with @surface_image
  end

  def family
    respond_with @spot, layout: !request.xhr?
  end

  def svg
    respond_with @spot, layout: !request.xhr?
  end

  def zooms
    respond_with @surface_image, layout: !request.xhr?
  end

  def map
    respond_with @surface_image, layout: !request.xhr?
  end

  def create
    @image = AttachmentFile.new(image_params)
    @surface.images << @image if @image.save
    respond_with @image, location: adjust_url_by_requesting_tab(request.referer), action: "error"
  end


  def destroy
    #@image = AttachmentFile.find(params[:id])
    @surface.images.delete(@image)
    respond_with @image, location: adjust_url_by_requesting_tab(request.referer)
  end

  def update
    @image = AttachmentFile.find(params[:id])
    @surface_image.update(surface_image_params) unless params[:surface_image].blank?
    #@surface.images << @image
    respond_with @surface_image, location: adjust_url_by_requesting_tab(request.referer)
  end

  def link_by_global_id
    @image = AttachmentFile.joins(:record_property).where(record_properties: {global_id: params[:global_id]}).readonly(false).first
    @surface.images << @image if @image
    respond_with @image, location: adjust_url_by_requesting_tab(request.referer), action: "error"
  rescue
    duplicate_global_id
  end

  def fits_image
    send_data(@image.fits_image.to_blob, :type => 'image/png', :disposition => 'inline')
  end

  def tiles
    TileWorker.perform_async(@surface_image.id)
    respond_with @image, location: adjust_url_by_requesting_tab(request.referer)
  end

  def move_to_top
    #@surface.surface_images.find_by_image_id(@image.id).move_to_top
    @surface_image.move_to_top
    respond_with @image, location: adjust_url_by_requesting_tab(request.referer)
  end

  def move_higher
    #@surface.surface_images.find_by_image_id(@image.id).move_to_top
    @surface_image.move_higher
    respond_with @image, location: adjust_url_by_requesting_tab(request.referer)
  end

  def move_lower
    #@surface.surface_images.find_by_image_id(@image.id).move_to_top
    @surface_image.move_lower
    respond_with @image, location: adjust_url_by_requesting_tab(request.referer)
  end

  def choose_as_base
    @surface_image.update(wall: true)
    respond_with @image, location: adjust_url_by_requesting_tab(request.referer)
  end

  def unchoose_as_base
    @surface_image.update(wall: false)
    respond_with @image, location: adjust_url_by_requesting_tab(request.referer)
  end

  def move_to_bottom
    @surface_image.move_to_bottom
    respond_with @image, location: adjust_url_by_requesting_tab(request.referer)
  end

  def insert_at
    unless params["position"].blank?
      position = params["position"].to_i
      @surface_image.insert_at(position)
    end
    #respond_with @image, location: adjust_url_by_requesting_tab(request.referer)
    ret = {
      order: @surface_image.surface.surface_images.pluck(:image_id, :position)
    }
    render json: ret.to_json
  end

  def layer
    @surface_image.update(surface_layer_id: params["layer_id"])
    render :nothing => true
  end

  def calibrate_svg
    respond_with @surface_image
  end

  def calibrate
    respond_with @surface_image
  end

  private

  def surface_image_params
    params.require(:surface_image).permit(:corners_on_map, :corners_on_world, :surface_layer_id)
  end

  def image_params
    params.require(:attachment_file).permit(
      :name,
      :description,
      :md5hash,
      :data,
      :original_geometry,
      :affine_matrix_in_string,
      :user_id,
      :group_id,
      :published,
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
        :lost
      ]
    )
  end

  def find_surface
    @surface = Surface.includes(:record_property, {surface_images: :image}).find(params[:surface_id]).decorate
  end

  def find_resource
    @image = AttachmentFile.find(params[:id])
    @surface_image = @surface.surface_images.includes({surface: [:record_property, {surface_images: :image}]}).find_by_image_id(@image.id).decorate
    if params[:base_id]
      @base_image = @surface.surface_images.includes({surface: [:record_property, {surface_images: :image}]}).find_by_image_id(params[:base_id])

    end
  end


  def duplicate_global_id
    respond_to do |format|
      format.html { render "parts/duplicate_global_id", status: :unprocessable_entity }
      format.all { render body: nil, status: :unprocessable_entity }
    end
  end
end
