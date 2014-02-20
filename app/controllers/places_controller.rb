class PlacesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :upload]
  load_and_authorize_resource

  def index
    @search = Place.readables(current_user).search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @places = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @places

  end

  def show
    respond_with @place
  end

  def new
    @place = Place.new
    respond_with @place
  end

  def edit
    respond_with @place
  end

  def create
    @place = Place.new(place_params)
    @place.save
    respond_with @place
  end

  def update
    @place.update_attributes(place_params)
    respond_with @place
  end

  def destroy
    @place.destroy
    respond_with @place
  end

  def upload
    @place.attachment_files << AttachmentFile.new(data: params[:media])
    respond_with @place
  end

  private

  def place_params
    params.require(:place).permit(
      :name,
      :description,
      :latitude,
      :longitude,
      :elevation,
      :link_url,
      :doi,
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
    @place = Place.find(params[:id]).decorate
  end

end
