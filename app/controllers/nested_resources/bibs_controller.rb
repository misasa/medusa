class NestedResources::BibsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @bibs = @parent.bibs
    respond_with @bibs
  end

  def update
    @bib = Bib.find(params[:id])
    @parent.bibs << @bib
    @parent.save
    respond_with @bib
  end

  def destroy
    @bib = Bib.find(params[:id])
    @parent.bibs.delete(@bib)
    respond_with @bib, location: request.referer
  end

  private

  def find_resource
    resource_name = params[:parent_resource]
    resource_class = resource_name.camelize.constantize
    @parent = resource_class.find(params["#{resource_name}_id"])
  end

end
