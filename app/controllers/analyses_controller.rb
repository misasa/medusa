class AnalysesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :new, :create, :upload,:bundle_edit, :bundle_update, :import, :table, :castemls]
  before_action :find_resources, only: [:bundle_edit, :bundle_update, :table, :castemls]
  load_and_authorize_resource

  def index
    @search = Analysis.readables(current_user).search(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @analyses = @search.result.includes([:stone, :device, chemistries: :measurement_item]).page(params[:page]).per(params[:per_page])
    respond_with @analyses
  end

  def new
    respond_to do |format|
      format.csv do
        mc = MeasurementCategory.find(params[:measurement_category_id])
        render csv: [Analysis.new], style: "#{mc.name}".to_sym, filename: "my_#{mc.name.gsub(' ','')}"
      end
    end
  end

  def show
    respond_with @analysis
  end

  def edit
    respond_with @analysis, layout: !request.xhr?
  end

  def create
    @analysis = Analysis.new(analysis_params)
    @analysis.save
    respond_with @analysis
  end

  def update
    @analysis.update_attributes(analysis_params)
    respond_with @analysis
  end

  def picture
    respond_with @analysis, layout: !request.xhr?
  end

  def property
    respond_with @analysis, layout: !request.xhr?
  end

  def destroy
    @analysis.destroy
    respond_with @analysis
  end

  def upload
    @analysis = Analysis.find(params[:id])
    @analysis.attachment_files << AttachmentFile.new(data: params[:data])
    respond_with @analysis
  end

  def bundle_edit
    respond_with @analyses
  end

  def bundle_update
    @analyses.each { |analysis| analysis.update_attributes(analysis_params.only_presence) }
    render :bundle_edit
  end

  def import
    if Analysis.import_csv(params[:data])
      redirect_to analyses_path
    else
      render "import_invalid"
    end
  end

  def table
    respond_with @analyses
  end

  def castemls
    send_data(Analysis.to_castemls(@analyses),
              :type => 'application/xml',
              :filename => 'my-great-analysis.pml', 
              :disposition=>'attached')
  end

  private

  def analysis_params
    params.require(:analysis).permit(
      :name,
      :description,
      :stone_id,
      :stone_global_id,
      :technique_id,
      :device_id,
      :operator,
      :user_id,
      :group_id,
      :published,
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
      ]
    )
  end

  def find_resource
    @analysis = Analysis.find(params[:id]).decorate
  end

  def find_resources
    @analyses = Analysis.where(id: params[:ids])
  end

end
