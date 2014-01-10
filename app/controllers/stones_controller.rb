class StonesController < ApplicationController

  def index
    @search = Stone.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @stones = @search.result.page(params[:page]).per(params[:per_page])
  end

  def create
    @stone = Stone.new(stone_params)
    if @stone.save
      redirect_to stones_path
    else
      # TODO: When validation error .....
    end
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
