class NestedResources::StonesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @stones = @parent.send(params[:association_name])
    respond_with @stones
  end

  def update
    @stone = Stone.find(params[:id])
    @parent.send(params[:association_name]) << @stone
    @parent.save
    respond_with @stone
  end

  def destroy
    @stone = Stone.find(params[:id])
    @parent.send(params[:association_name]).delete(@stone)
    respond_with @stone
  end

  private

  def find_resource
    resource_name = params[:parent_resource]
    resource_class = resource_name.camelize.constantize
    @parent = resource_class.find(params["#{resource_name}_id"])
  end

end
