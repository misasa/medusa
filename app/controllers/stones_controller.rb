class StonesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :upload]
  load_and_authorize_resource

  def index
    @search = Stone.readables(current_user).search(params[:q])
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

  def property
    respond_with @stone, layout: !request.xhr?
  end

  def upload
    @stone = Stone.find(params[:id])
    @stone.attachment_files << AttachmentFile.new(data: params[:image])
    @stone.save
    respond_with @stone
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
      :description,
      record_property_attributes: [
        :global_id,
        :user_id,
        :group_id,
        :owner_readable,
        :owner_writable,
        :group_readable,
        :group_writable,
        :guest_readable,
        :guest_writable,
        :published
      ]
    )
  end

  def find_resource
    @stone = Stone.find(params[:id]).decorate
  end

end
