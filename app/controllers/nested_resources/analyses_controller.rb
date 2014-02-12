class NestedResources::AnalysesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @analyses = @parent.analyses
    respond_with @analyses
  end

  def update
    @analysis = Analysis.find(params[:id])
    @parent.analyses << @analysis
    @parent.save
    respond_with @analysis
  end

  def destroy
    @analysis = Analysis.find(params[:id])
    @parent.analyses.delete(@analysis)
    respond_with @analysis
  end

  private

  def find_resource
    resource_name = params[:parent_resource]
    resource_class = resource_name.camelize.constantize
    @parent = resource_class.find(params["#{resource_name}_id"])
  end

end
