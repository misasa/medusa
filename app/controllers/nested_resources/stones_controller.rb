class NestedResources::StonesController < ApplicationController
  respond_to  :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @stones = @parent.send(params[:association_name])
    respond_with @stones
  end

  def create
    @stone = Stone.new(stone_params)
    @parent.send(params[:association_name]) << @stone
    respond_with @stone, location: request.referer
  end

  def update
    @stone = Stone.find(params[:id])
    @parent.send(params[:association_name]) << @stone
    respond_with @stone
  end

  def destroy
    @stone = Stone.find(params[:id])
    @parent.send(params[:association_name]).delete(@stone)
    respond_with @stone, location: request.referer
  end

  def link_by_global_id
    @stone = Stone.joins(:record_property).where(record_properties: {global_id: params[:global_id]}).readonly(false)
    @parent.send(params[:association_name]) << @stone
    respond_with @stone, location: request.referer
  end

  private

  def stone_params
    params.require(:stone).permit(
      :name,
      :physical_form_id,
      :classification_id,
      :quantity,
      :quantity_unit,
      :tag_list,
      :parent_id,
      :box_id,
      :place_id,
      :description,
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
