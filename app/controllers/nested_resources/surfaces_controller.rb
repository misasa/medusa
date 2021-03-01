class NestedResources::SurfacesController < ApplicationController

    respond_to :html, :xml, :json
    before_action :find_resource
    load_and_authorize_resource

    def index
      @surfaces = @parent.surfaces
      respond_with @surfaces
    end

    def create
      @surface = Surface.new(surface_params)
      @parent.surfaces << @surface if @surface.save
      respond_with @surface, location: adjust_url_by_requesting_tab(request.referer), action: "error"
    end

    def update
      @surface = Surface.find(params[:id])
      @parent.surfaces << @surface
      respond_with @surface, location: adjust_url_by_requesting_tab(request.referer)
    end

    def destroy
      @surface = Surface.find(params[:id])
      @parent.surfaces.delete(@surface)
      respond_with @surface, location: adjust_url_by_requesting_tab(request.referer)
    end

    def link_by_global_id
      @surface = Surface.joins(:record_property).where(record_properties: {global_id: params[:global_id]}).readonly(false).first
      @parent.surfaces << @surface if @surface
      respond_with @surface, location: adjust_url_by_requesting_tab(request.referer), action: "error"
    rescue
      duplicate_global_id
    end

    private

    def find_resource
      resource_name = params[:parent_resource]
      resource_class = resource_name.camelize.constantize
      @parent = resource_class.find(params["#{resource_name}_id"])
    end

    def surface_params
      params.require(:surface).permit(
        :name,
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
        format.all { render body: nil, status: :unprocessable_entity }
      end
    end

  end
