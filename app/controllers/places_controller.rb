class PlacesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create,:bundle_edit, :bundle_update, :download_bundle_card, :download_label, :download_bundle_label]
  before_action :find_resources, only: [:bundle_edit, :bundle_update, :download_bundle_card, :download_bundle_label]
  load_and_authorize_resource

  def index
    @search = Place.readables(current_user).search(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @places = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @places
  end

  def show
    respond_with @place
  end

  def edit
    respond_with @place, layout: !request.xhr?
  end

  def create
    @place = Place.new(place_params)
    @place.save
    respond_with @place
  end

  def update
    @place.update_attributes(place_params)
    respond_with @place
  end

  def map
    respond_with @stone, layout: !request.xhr?
  end

  def property
    respond_with @stone, layout: !request.xhr?
  end

  def destroy
    @place.destroy
    respond_with @place
  end

  def upload
    @place.attachment_files << AttachmentFile.new(data: params[:data])
    respond_with @place
  end

  def link_attachment_file_by_global_id
    @place.attachment_files << AttachmentFile.joins(:record_property).where(record_properties: {global_id: params[:global_id]})
    redirect_to :back
  end

  def link_stone_by_global_id
    @place.stones << Stone.joins(:record_property).where(record_properties: {global_id: params[:global_id]}).readonly(false)
    redirect_to :back
  end

  def bundle_edit
    respond_with @places
  end

  def bundle_update
    @places.each { |place| place.update_attributes(place_params.only_presence) }
    render :bundle_edit
  end

  def download_bundle_card
    method = (params[:a4] == "true") ? :build_a_four : :build_cards
    report = Place.send(method, @places)
    send_data(report.generate, filename: "places.pdf", type: "application/pdf")
  end

  def download_label
    place = Place.find(params[:id])
    send_data(place.build_label, filename: "place_#{place.id}.csv", type: "text/csv")
  end

  def download_bundle_label
    label = Place.build_bundle_label(@places)
    send_data(label, filename: "places.csv", type: "text/csv")
  end

  private

  def place_params
    params.require(:place).permit(
      :name,
      :description,
      :latitude,
      :longitude,
      :elevation,
      :link_url,
      :doi,
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
    @place = Place.find(params[:id]).decorate
  end

  def find_resources
    @places = Place.where(id: params[:ids])
  end

end
