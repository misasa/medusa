require 'histogram/array'
class SpecimensController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :bundle_edit, :bundle_update, :download_card, :download_bundle_card, :download_label, :download_bundle_label, :download_bundle_list]
  before_action :find_resources, only: [:bundle_edit, :bundle_update, :download_bundle_card, :download_bundle_label, :download_bundle_list]
  load_and_authorize_resource

  def index
    @search = Specimen.includes(:classification, :physical_form).readables(current_user).search(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @specimens = @search.result.page(params[:page]).per(params[:per_page])
    @search_columns = SearchColumn.model_is(Specimen).user_is(current_user)
    @search_columns = params[:toggle_column] == "expand" ? @search_columns.display_expand : @search_columns.display_always
    respond_with @specimens
  end

  def show
    unless params[:measurement_category_id]
      params[:measurement_category_id] = MeasurementCategory.first.id if MeasurementCategory.first
    end

    respond_with @specimen
  end

  def edit
    respond_with @specimen, layout: !request.xhr?
  end
  
  def detail_edit
    @specimen_custom_attributes = @specimen.set_specimen_custom_attributes
    respond_with @specimen, layout: !request.xhr?
  end

  def create
    @specimen = Specimen.new(specimen_params)
    @specimen.save
    respond_with @specimen
  end

  def update
    @specimen.update_attributes(specimen_params)
    if params[:sesar_upload] && @specimen.errors.blank?
      sesar_upload
    elsif params[:sesar_download] && @specimen.errors.blank?
      sesar_download
    else
      respond_with @specimen
    end
  end
  
  def destroy
    @specimen.destroy
    respond_with @specimen
  end

  def quantity_history
    respond_with @specimen, layout: !request.xhr?
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

  def chemistries
    analyses = Analysis.where(specimen_id: @specimen.self_and_descendants)
    return if analyses.count == 0
    @measurement_item = MeasurementItem.find(params[:measurement_item_id])
    @chemistries = Chemistry.where(analysis_id: analyses.map(&:id), measurement_item_id: @measurement_item.id).order(:value)
    (bins, freqs) = @chemistries.pluck(:value).histogram(10)
    min = @chemistries.first.value
    max = @chemistries.last.value

    @graph = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: "#{@measurement_item.display_in_html} min:#{min} max:#{max}")
      f.xAxis(categories: bins)
      f.series(name:  @measurement_item.display_in_html, data: freqs, type: 'column')
    end

  end

  def show_place
    @place = @specimen.place
    #respond_with @place, layout: false
    respond_to do |format|
      format.html { redirect_to @place }
      format.xml { render :xml => @place }
      format.json { render :json => @place }
    end
  end

  def create_place
    @place = Place.new(place_params)
    @place.name = "locality of #{@specimen.name}" unless @place.name
    if @place.save
      @specimen.place = @place
      @specimen.save
    end
#    respond_with @place
    respond_to do |format|
      format.html { redirect_to @specimen }
      format.xml { render :xml => @place }
      format.json { render :json => @place }
    end
  end

  def property
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
    send_data(specimen.build_label, filename: "specimen_#{specimen.id}.label", type: "text/label")
  end

  def download_bundle_label
    label = Specimen.build_bundle_label(@specimens)
    send_data(label, filename: "specimens.label", type: "text/label")
  end

  def download_bundle_list
    csv = Specimen.build_bundle_list(@specimens)
    send_data(csv, filename: "specimens.csv", type: "text/csv")    
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
    respond_with @specimen
  end

  def sesar_download
    @sesar_json = SesarJson.sync(@specimen)
    if @sesar_json.errors.messages.blank?
      @sesar_json.update_specimen(@specimen)
    else
      @specimen.errors.add(:sesar_download, @sesar_json.errors.messages)
    end
    respond_with @specimen
  end

  private

  def specimen_params
    params.require(:specimen).permit(
      :name,
      :specimen_type,
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
      :disposed,
      :lost,
      :igsn,
      :abs_age,
      :age_min,
      :age_max,
      :age_unit,
      :size,
      :size_unit,
      :collector,
      :collector_detail,
      :collected_at,
      :collected_end_at,
      :collection_date_precision,
      :fixed_in_box,
      record_property_attributes: [
        :id,
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
        :lost
      ],
      specimen_custom_attributes_attributes: [
        :id,
        :specimen_id,
        :custom_attribute_id,
        :value
      ]
    )
  end


  def place_params
    params.require(:place).permit(
      :name,
      :description,
      :latitude,
      :latitude_dms_direction,
      :latitude_dms_deg,
      :latitude_dms_min,
      :latitude_dms_sec,
      :longitude,
      :longitude_dms_direction,
      :longitude_dms_deg,
      :longitude_dms_min,
      :longitude_dms_sec,
      :elevation,
      :link_url,
      :doi,
      :user_id,
      :group_id,
      :published,
      record_property_attributes: [
        :id,
        :global_id,
        :user_id,
        :group_id,
        :owner_readable,
        :owner_writable,
        :group_readable,
        :group_writable,
        :guest_readable,
        :guest_writable,
        :lost
      ]
    )
  end

  def find_resource
    @specimen = Specimen.includes(:classification, :physical_form, :specimen_custom_attributes, :attachment_files, :bibs, {children: [:record_property, :physical_form]}).find(params[:id]).decorate
    #@full_analyses = Analysis.includes(:chemistries).where(specimen_id: @specimen.self_and_descendants)
    @divide_specimen = Specimen.find(params[:id])
    @divide_specimen.children.build
  end

  def find_resources
    @search_columns = SearchColumn.model_is(Specimen).user_is(current_user)
    @search_columns = params[:toggle_column] == "expand" ? @search_columns.display_expand : @search_columns.display_always
    @specimens = Specimen.where(id: params[:ids])
  end

end
