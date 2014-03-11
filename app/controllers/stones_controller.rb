class StonesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :upload, :bundle_edit, :bundle_update, :download_card, :download_bundle_card]
  before_action :find_resources, only: [:bundle_edit, :bundle_update, :download_bundle_card]
  load_and_authorize_resource

  def index
    @search = Stone.readables(current_user).search(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @stones = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @stones
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
    @stone.attachment_files << AttachmentFile.new(data: params[:data])
    respond_with @stone
  end

  def bundle_edit
    respond_with @stones
  end

  def bundle_update
    @stones.each { |stone| stone.update_attributes(stone_params.only_presence) }
    render :bundle_edit
  end

  def download_card
    report = Stone.find(params[:id]).build_card
    send_data(report.generate, filename: "stone.pdf", type: "application/pdf")
  end

  def download_bundle_card
    report = (params[:a4] == "true") ? Stone.build_a_four(@stones) : Stone.build_cards(@stones)
    send_data(report.generate, filename: "stones.pdf", type: "application/pdf")
  end

  private

  def stone_params
    params.require(:stone).permit(
      :name,
      :physical_form_id,
      :classification_id,
      :quantity,
      :quantity_unit,
      :tag_list,
      :parent_id,
      :box_id,
      :place_id,
      :description,
      :user_id,
      :group_id,
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
        :published,
        :published_at
      ]
    )
  end

  def find_resource
    @stone = Stone.find(params[:id]).decorate
  end

  def find_resources
    @stones = Stone.where(id: params[:ids])
  end

end
