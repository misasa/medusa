class NestedResources::PlacesController < ApplicationController

  respond_to :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    if @parent.respond_to?(:all_places)
      @places = @parent.all_places
    else
      @places = @parent.places
    end
    respond_with @places
  end
  
  def create
    @place = Place.new(place_params)
    @parent.places << @place if @place.save
    respond_with @place, location: adjust_url_by_requesting_tab(request.referer), action: "error"
  end

  def update
    @place = Place.find(params[:id])
    @parent.places << @place
    respond_with @place, location: adjust_url_by_requesting_tab(request.referer)
  end

  def destroy
    @place = Place.find(params[:id])
    @parent.places.delete(@place)
    respond_with @place, location: adjust_url_by_requesting_tab(request.referer)
  end

  def link_by_global_id
    @place = Place.joins(:record_property).where(record_properties: {global_id: params[:global_id]}).readonly(false).first
    @parent.places << @place if @place
    respond_with @place, location: adjust_url_by_requesting_tab(request.referer), action: "error"
  rescue
    duplicate_global_id
  end

  private

  def find_resource
    resource_name = params[:parent_resource]
    resource_class = resource_name.camelize.constantize
    @parent = resource_class.find(params["#{resource_name}_id"])
  end
  
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

  def duplicate_global_id
    respond_to do |format|
      format.html { render "parts/duplicate_global_id", status: :unprocessable_entity }
      format.all { render nothing: true, status: :unprocessable_entity }
    end
  end

end
