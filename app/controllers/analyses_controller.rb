class AnalysesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  def index
    @search = Analysis.readables(current_user).search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @analyses = @search.result.includes([:stone, chemistries: :measurement_item]).page(params[:page]).per(params[:per_page])
    respond_with @analyses
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

  def destroy
    @analysis.destroy
    respond_with @analysis
  end

  def upload
    @analysis.attachment_files << AttachmentFile.new(data: params[:media])
    respond_with @analysis
  end

  private

  def analysis_params
    params.require(:analysis).permit(
      :name,
      :description,
      :stone_id,
      :technique_id,
      :device_id,
      :operator
    )
  end

  def find_resource
    @analysis = Analysis.find(params[:id])
  end

end
