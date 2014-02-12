class NestedResources::PlacesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @places = @parent.places
    respond_with @places
  end

  def update
    @place = Place.find(params[:id])
    @parent.places << @place
    @parent.save
    respond_with @place
  end

  def destroy
    @place = Place.find(params[:id])
    @parent.places.delete(@place)
    respond_with @place
  end

  private

  def find_resource
    @parent = AttachmentFile.find(params[:attachment_file_id])
  end

end
