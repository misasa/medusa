class NestedResources::SpotsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @spots = AttachmentFile.find(params[:attachment_file_id]).spots
    respond_with @spots
  end

  def update
    @spot = Spot.find(params[:id])
    @spot.attachment_file_id = params[:attachment_file_id].to_i
    @spot.save
    respond_with @spot
  end

  def destroy
    @spot = Spot.find(params[:id])
    @spot.destroy
    respond_with @spot
  end

end
