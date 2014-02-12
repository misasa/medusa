class NestedResources::BoxesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @boxes = @parent.send(params[:association_name])
    respond_with @boxes
  end

  def update
    @box = Box.find(params[:id])
    @parent.send(params[:association_name]) << @box
    @parent.save
    respond_with @box
  end

  def destroy
    @box = Box.find(params[:id])
    @parent.send(params[:association_name]).delete(@box)
    respond_with @box
  end

  private

  def find_resource
    resource_name = params[:parent_resource]
    resource_class = resource_name.camelize.constantize
    @parent = resource_class.find(params["#{resource_name}_id"])
  end

end
