class StonesController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @search = Stone.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @stones = @search.result.page(params[:page]).per(params[:per_page])
  end

  def create
    @stone = Stone.new(stone_params)
    @stone.save
    respond_with @stone
  end

  private

  def stone_params
    params.require(:stone).permit(
      :name,
      :physical_form_id,
      :classification_id,
      :tag_list
    )
  end

end
