class SpotsController < ApplicationController
  respond_to :html, :xml, :json, :svg
  before_action :find_resource, except: [:index, :bundle_edit, :bundle_update]
  before_action :find_resources, only: [:bundle_edit, :bundle_update]

  load_and_authorize_resource

  def index
    redirect_to attachment_files_path
  end

  def edit
    respond_with @spot, layout: !request.xhr?
  end

  def show
    respond_with @spot, layout: !request.xhr?
  end

  def family
    respond_with @spot, layout: !request.xhr?
  end

  def update
    @spot.update_attributes(spot_params)
    #respond_with @spot, location: attachment_file_path(@spot.attachment_file)
    respond_with @spot
  end
  
  def property
    respond_with @spot, layout: !request.xhr?
  end
  
  def picture
    respond_with @spot, layout: !request.xhr?
  end

  def destroy
    attachment_file = @spot.attachment_file
    @spot.destroy
    respond_with attachment_file
  end

  def analysis
    render json: @spot.get_analysis.to_json(include: { chemistries: { include: [:measurement_item, :unit] } })
  end

  def bundle_edit
    respond_with @spots
  end

  def bundle_update
    @spots.each { |spot| spot.update_attributes(spot_params.only_presence) }
    render :bundle_edit
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

  def find_resources
    @spots = Spot.where(id: params[:ids])
  end

end
