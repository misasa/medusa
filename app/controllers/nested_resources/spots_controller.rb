class NestedResources::SpotsController < ApplicationController
  include TabParam

  respond_to :html, :xml, :json, :svg
  before_action :find_resource, except: [:index, :create]
  before_action :find_resources, only: [:create, :update, :destroy]
  load_and_authorize_resource

  def index
    @spots = AttachmentFile.find(params[:attachment_file_id]).spots
    respond_with @spots
  end

  def create
    @spot = Spot.new(spot_params)
    @parent.spots << @spot
    respond_with @spot, location: add_tab_param(request.referer)
  end

  def update
    @spot = Spot.find(params[:id])
    @parent.spots << @spot
    respond_with @spot, location: add_tab_param(request.referer)
  end

  def destroy
    @spot.destroy
    @parent.spots.delete(@spot)
    respond_with @spot, location: add_tab_param(request.referer)
  end

  private

  def spot_params
    params.require(:spot).permit(
      :name,
      :description,
      :spot_x,
      :spot_y,
      :target_uid,
      :radius_in_percent,
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
  end

  def find_resources
    @parent = AttachmentFile.find(params[:attachment_file_id])
  end

end
