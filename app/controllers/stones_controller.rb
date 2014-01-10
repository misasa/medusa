class StonesController < ApplicationController

  def index
    @search = Stone.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @stones = @search.result.page(params[:page]).per(params[:per_page])
  end

end
