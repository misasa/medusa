class Api::V1::SpotsController < Api::ApplicationController
  before_action :find_resource, except: [:index]

  load_and_authorize_resource

#  def index
#    redirect_to attachment_files_path
#  end
  def index
    spots = Spot.order(created_at: :desc)
    render json: spots, status: :ok
  end

  def show
    render json: @spot, status: :ok
  end

  def create
    spot = Spot.new(spot_params)
    if spot.save
      render json: spot, status: :created
    else
      render json: spot.errors, status: :bad_request
    end
  end

  def update
    if @spot.update(spot_params)
      render json: @spot, status: :ok
    else
      render json: @spot.errors, status: :bad_request
    end    
  end

  def destroy
    if @spot.destroy
      render json: nil, status: :no_content
    else
      render json: @spot.errors, status: :bad_request
    end
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
      ]
    )
  end

  def find_resource
    @spot = Spot.find(params[:id]).decorate
  end

end
