class SpecimensController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :bundle_edit, :bundle_update, :download_card, :download_bundle_card, :download_label, :download_bundle_label]
  before_action :find_resources, only: [:bundle_edit, :bundle_update, :download_bundle_card, :download_bundle_label]
  load_and_authorize_resource

  def index
    @search = Specimen.includes(:classification, :physical_form).readables(current_user).search(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @specimens = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @specimens
  end

  def show
    respond_with @specimen
  end

  def edit
    respond_with @specimen, layout: !request.xhr?
  end
  
  def detail_edit
    respond_with @specimen, layout: !request.xhr?
  end

  def create
    @specimen = Specimen.new(specimen_params)
    @specimen.save
    respond_with @specimen
  end

  def update
    @specimen.update_attributes(specimen_params)
    sesar_upload if params[:sesar_upload] && @specimen.errors.blank?
    respond_with @specimen
  end
  
  def destroy
    @specimen.destroy
    respond_with @specimen
  end

  def family
    respond_with @specimen, layout: !request.xhr?
  end

  def picture
    respond_with @specimen, layout: !request.xhr?
  end

  def map
    respond_with @specimen, layout: !request.xhr?
  end

  def property
    respond_with @specimen, layout: !request.xhr?
  end
  
  def custom_attribute
    @specimen_custom_attributes = @specimen.set_specimen_custom_attributes
    respond_with @specimen, layout: !request.xhr?
  end

  def bundle_edit
    respond_with @specimens
  end

  def bundle_update
    @specimens.each { |specimen| specimen.update_attributes(specimen_params.only_presence) }
    render :bundle_edit
  end

  def download_card
    report = Specimen.find(params[:id]).build_card
    send_data(report.generate, filename: "specimen.pdf", type: "application/pdf")
  end

  def download_bundle_card
    method = (params[:a4] == "true") ? :build_a_four : :build_cards
    report = Specimen.send(method, @specimens)
    send_data(report.generate, filename: "specimens.pdf", type: "application/pdf")
  end

  def download_label
    specimen = Specimen.find(params[:id])
    send_data(specimen.build_label, filename: "specimen_#{stone.id}.csv", type: "text/csv")
  end

  def download_bundle_label
    label = Specimen.build_bundle_label(@specimens)
    send_data(label, filename: "specimens.csv", type: "text/csv")
  end
  
  def sesar_upload
    @sesar = Sesar.from_active_record(@specimen)
    if @sesar.save
      @specimen.update_attributes(igsn: @sesar.igsn)
    else
      @sesar.errors.each do |key, value|
        @specimen.errors.add(key, value)
      end
    end
  end

  private

  def specimen_params
    params.require(:specimen).permit(
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
      specimen_custom_attributes_attributes: [
        :id,
        :specimen_id,
        :custom_attribute_id,
        :value
      ]
    )
  end

  def find_resource
    @specimen = Specimen.find(params[:id]).decorate
  end

  def find_resources
    @specimens = Specimen.where(id: params[:ids])
  end

end
