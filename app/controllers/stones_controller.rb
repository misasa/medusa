class StonesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :bundle_edit, :bundle_update, :download_card, :download_bundle_card, :download_label, :download_bundle_label]
  before_action :find_resources, only: [:bundle_edit, :bundle_update, :download_bundle_card, :download_bundle_label]
  load_and_authorize_resource

  def index
    @search = Stone.includes(:classification, :physical_form).readables(current_user).search(params[:q])
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
  
  def detail_edit
    respond_with @stone, layout: !request.xhr?
  end

  def create
    @stone = Stone.new(stone_params)
    @stone.save
    respond_with @stone
  end

  def update
    @stone.update_attributes(stone_params)
    sesar_upload if params[:sesar_upload] && @stone.errors.blank?
    respond_with @stone
  end
  
  def destroy
    @stone.destroy
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
  
  def custom_attribute
    @stone_custom_attributes = @stone.set_stone_custom_attributes
    respond_with @stone, layout: !request.xhr?
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
    method = (params[:a4] == "true") ? :build_a_four : :build_cards
    report = Stone.send(method, @stones)
    send_data(report.generate, filename: "stones.pdf", type: "application/pdf")
  end

  def download_label
    stone = Stone.find(params[:id])
    send_data(stone.build_label, filename: "stone_#{stone.id}.csv", type: "text/csv")
  end

  def download_bundle_label
    label = Stone.build_bundle_label(@stones)
    send_data(label, filename: "stones.csv", type: "text/csv")
  end
  
  def sesar_upload
    @sesar = Sesar.from_active_record(@stone)
    if @sesar.save
      @stone.update_attributes(igsn: @sesar.igsn)
    else
      @sesar.errors.each do |key, value|
        @stone.errors.add(key, value)
      end
    end
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
      :parent_global_id,
      :parent_id,
      :box_global_id,
      :box_id,
      :place_global_id,
      :place_id,
      :description,
      :user_id,
      :group_id,
      :published,
      :igsn,
      :age_min,
      :age_max,
      :age_unit,
      :size,
      :size_unit,
      :collector,
      :collector_detail,
      :collected_at,
      :collection_date_precision,
      record_property_attributes: [
        :global_id,
        :user_id,
        :group_id,
        :owner_readable,
        :owner_writable,
        :group_readable,
        :group_writable,
        :guest_readable,
        :guest_writable
      ],
      stone_custom_attributes_attributes: [
        :id,
        :stone_id,
        :custom_attribute_id,
        :value
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
