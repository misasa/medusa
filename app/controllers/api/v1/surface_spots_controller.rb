class Api::V1::SurfaceSpotsController < Api::ApplicationController

  before_action :find_resource, except: [:index, :create]
  before_action :find_resources, only: [:index, :create, :update, :destroy]
  #load_and_authorize_resource

  def index
    @spots = @parent.spots
    render json: SpotDecorator.decorate_collection(@spots)
  end

  def create
    spot = Spot.new(spot_params)
    if spot.save
      @parent.direct_spots << spot
      render json: spot.decorate, status: :created
    else
      render json: spot.errors, status: :bad_request
    end
  end

  def update
    @spot = Spot.find(params[:id])
    @parent.direct_spots << @spot
    render json: @spot  
  end

  def destroy
    @spot.destroy
    @parent.spots.delete(@spot)
    respond_with @spot, location: adjust_url_by_requesting_tab(request.referer)
  end

  private

  def spot_params
    params.require(:spot).permit(
      :name,
      :description,
      :spot_x,
      :spot_y,
      :world_x,
      :world_y,
      :target_uid,
      :radius_in_percent,
      :radius_in_um,
      :stroke_color,
      :stroke_width,
      :fill_color,
      :opacity,
      :with_cross,
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
        :published_at
      ]
    )
  end

  def find_resource
    @spot = Spot.find(params[:id]).decorate
    authorize!(params[:action].to_sym, @spot)
  end

  def find_resources
    @parent = if params[:attachment_file_id]
                AttachmentFile.find(params[:attachment_file_id])
              elsif params[:surface_id]
                Surface.find(params[:surface_id])
              end
  end

end
