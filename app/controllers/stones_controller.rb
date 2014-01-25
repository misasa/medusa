class StonesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update, :family, :picture, :map]
  load_and_authorize_resource

  def index
    @search = Stone.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @stones = @search.result.page(params[:page]).per(params[:per_page])
  end

  def show
    respond_with @stone
  end

  def edit
    respond_with @stone, layout: !request.xhr?
  end

  def create
    @stone = Stone.new(stone_params)
    @stone.save
    respond_with @stone
  end

  def update
    @stone.update_attributes(stone_params)
    respond_with @stone
  end

  def family
    respond_with @stone, layout: !request.xhr?
  end

  def picture
    respond_with @stone, layout: !request.xhr?
  end

  def map
    respond_with @stone, layout: !request.xhr?
  end

  private

  def stone_params
    params.require(:stone).permit(
      :name,
      :physical_form_id,
      :classification_id,
      :quantity,
      :tag_list,
      :parent_id,
      :box_id,
      :place_id,
      :description
    )
  end

  def find_resource
    @stone = Stone.find(params[:id]).decorate
  end

end
