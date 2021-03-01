class NestedResources::AnalysesController < ApplicationController

  respond_to :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @analyses = @parent.analyses
    respond_with @analyses
  end

  def create
    @analysis = Analysis.new(analysis_params)
    @parent.analyses << @analysis if @analysis.save
    respond_with @analysis, location: adjust_url_by_requesting_tab(request.referer), action: "error"

  end

  def update
    @parent.analyses << @analysis
    respond_with @analysis, location: adjust_url_by_requesting_tab(request.referer)
  end

  def destroy
    @parent.analyses.delete(@analysis)
    respond_with @analysis, location: adjust_url_by_requesting_tab(request.referer)
  end

  def link_by_global_id
    @analysis = Analysis.joins(:record_property).where(record_properties: {global_id: params[:global_id]}).readonly(false).first
    @parent.analyses << @analysis if @analysis
    respond_with @analysis, location: adjust_url_by_requesting_tab(request.referer), action: "error"
  rescue
    duplicate_global_id
  end

  private

  def analysis_params
    params.require(:analysis).permit(
      :name,
      :description,
      :specimen_id,
      :technique_id,
      :device_id,
      :operator,
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
    resource_name = params[:parent_resource]
    resource_class = resource_name.camelize.constantize
    @parent = resource_class.find(params["#{resource_name}_id"])
  end

  def duplicate_global_id
    respond_to do |format|
      format.html { render "parts/duplicate_global_id", status: :unprocessable_entity }
      format.all { render body: nil, status: :unprocessable_entity }
    end
  end
end
