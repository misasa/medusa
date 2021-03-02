class AnalysesController < ApplicationController
  respond_to :html, :xml, :json, :pml
  before_action :find_resource, except: [:index, :new, :create, :bundle_edit, :bundle_update, :import, :table, :castemls]
  before_action :find_resources, only: [:bundle_edit, :bundle_update, :table, :castemls]
  load_and_authorize_resource

  def index
    @search = Analysis.readables(current_user).ransack(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @analyses = @search.result.includes([:specimen, :device, chemistries: :measurement_item]).page(params[:page]).per(params[:per_page])
    respond_with @analyses
  end

  def new
    respond_to do |format|
      format.csv do
        mc = MeasurementCategory.find(params[:measurement_category_id])
        render csv: [Analysis.new], style: "#{mc.name}".to_sym, filename: "my-analyses"
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
    @analysis.update(analysis_params)
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

  def bundle_edit
    respond_with @analyses
  end

  def bundle_update
    @analyses.each { |analysis| analysis.update(analysis_params.only_presence) }
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

  def casteml
    send_data(Analysis.to_castemls([@analysis]),
              :type => 'application/xml',
              :filename => @analysis.global_id + '.pml', 
              :disposition=>'attached')
  end

  private

  def analysis_params
    params.require(:analysis).permit(
      :name,
      :description,
      :specimen_id,
      :specimen_global_id,
      :technique_id,
      :device_id,
      :operator,
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
        :published,
        :lost
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
