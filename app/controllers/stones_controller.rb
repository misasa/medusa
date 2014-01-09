class StonesController < ApplicationController

  def index
    @q = Stone.search(params[:q])
    @stones = @q.result(distinct: true)
  end

end
