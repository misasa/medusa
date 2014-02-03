class Boxes::StonesController < ApplicationController
  respond_to :json

  def index
    boxed_stones = Stone.where(box_id: params[:box_id])
    respond_with boxed_stones
  end

  def update
    stone = Stone.find(params[:id])
    stone.box_id = params[:box_id].to_i
    stone.save
    respond_with stone
  end

end
