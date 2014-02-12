class PlacesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  def index
    @places = Place.all
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
      :elevation
    )
  end

  def find_resource
    @place = Place.find(params[:id])
  end

end
