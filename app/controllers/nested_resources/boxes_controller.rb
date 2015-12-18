class NestedResources::BoxesController < ApplicationController

  respond_to :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @boxes = @parent.send(params[:association_name])
    respond_with @boxes
  end
  
  def create
    @box = Box.new(box_params)
    @parent.send(params[:association_name]) << @box if @box.save
    respond_with @box, location: adjust_url_by_requesting_tab(request.referer), action: "error"
  end

  def update
    @box = Box.find(params[:id])
    @parent.send(params[:association_name]) << @box
    respond_with @box, location: adjust_url_by_requesting_tab(request.referer)
  end

  def destroy
    @box = Box.find(params[:id])
    @parent.send(params[:association_name]).delete(@box)
    respond_with @box, location: adjust_url_by_requesting_tab(request.referer)
  end

  def link_by_global_id
    @box = Box.joins(:record_property).where(record_properties: {global_id: params[:global_id]}).readonly(false).first
    @parent.send(params[:association_name]) << @box if @box
    respond_with @box, location: adjust_url_by_requesting_tab(request.referer), action: "error"
  rescue
    duplicate_global_id
  end
  
  def inventory
    @box= Box.find(params[:id])
    @box.update_attributes(parent_id: params[:box_id])
    @box.paths.current.first.update_attribute(:checked_at, Time.now) if @box.paths.current.first
    respond_with @box
  end

  private
  
  def box_params
    params.require(:box).permit(
      :name,
      :parent_id,
      :position,
      :path,
      :box_type_id,
      :tag_list,
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
    resource_name = params[:parent_resource]
    resource_class = resource_name.camelize.constantize
    @parent = resource_class.find(params["#{resource_name}_id"])
  end

  def duplicate_global_id
    respond_to do |format|
      format.html { render "parts/duplicate_global_id", status: :unprocessable_entity }
      format.all { render nothing: true, status: :unprocessable_entity }
    end
  end

end
