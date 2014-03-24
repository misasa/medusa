class NestedResources::BoxesController < ApplicationController
  include TabParam

  respond_to :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @boxes = @parent.send(params[:association_name])
    respond_with @boxes
  end
  
  def create
    @box = Box.new(box_params)
    @parent.send(params[:association_name]) << @box
    respond_with @box, location: add_tab_param(request.referer)
  end

  def update
    @box = Box.find(params[:id])
    @parent.send(params[:association_name]) << @box
    respond_with @box, location: add_tab_param(request.referer)
  end

  def destroy
    @box = Box.find(params[:id])
    @parent.send(params[:association_name]).delete(@box)
    respond_with @box, location: add_tab_param(request.referer)
  end

  def link_by_global_id
    @box = Box.joins(:record_property).where(record_properties: {global_id: params[:global_id]}).readonly(false)
    @parent.send(params[:association_name]) << @box
    respond_with @box, location: add_tab_param(request.referer)
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

end
