class NestedResources::DaughtersController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @children = Stone.where(parent_id: params[:stone_id])
    respond_with @children
  end

  def update
    @child = Stone.find(params[:id])
    @child.parent_id = params[:stone_id].to_i
    @child.save
    respond_with @child
  end

  def destroy
    @child = Stone.find(params[:id])
    @child.parent_id = nil
    @child.save
    respond_with @child
  end

end
