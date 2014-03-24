class NestedResources::PlacesController < ApplicationController
  include TabParam

  respond_to :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @places = @parent.places
    respond_with @places
  end
  
  def create
    @place = Place.new(place_params)
    @parent.places << @place
    respond_with @place, location: add_tab_param(request.referer)
  end

  def update
    @place = Place.find(params[:id])
    @parent.places << @place
    respond_with @place, location: add_tab_param(request.referer)
  end

  def destroy
    @place = Place.find(params[:id])
    @parent.places.delete(@place)
    respond_with @place, location: add_tab_param(request.referer)
  end

  def link_by_global_id
    @place = Place.joins(:record_property).where(record_properties: {global_id: params[:global_id]}).readonly(false)
    @parent.places << @place
    respond_with @place, location: add_tab_param(request.referer)
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

end
