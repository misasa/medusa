class DaughtersController < ApplicationController
  respond_to :json

  def index
    daughters = Stone.where(parent_id: params[:stone_id])
    respond_with daughters
  end

  def update
    child = Stone.find(params[:id])
    child.parent_id = params[:stone_id].to_i
    child.save
    respond_with child
  end

end
