class TechniquesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create]
  load_and_authorize_resource
  layout "admin"
  
  def index
    @search = Technique.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @techniques = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @techniques
  end
  
  def show
    respond_with @technique
  end
  
  def edit
    respond_with @technique
  end
  
  def create
    @technique = Technique.new(technique_params)
    @technique.save
    respond_with(@technique, location: techniques_path)
  end
  
  def update
    @technique.update_attributes(technique_params)
    respond_with(@technique, location: techniques_path)
  end
  
  private
  
  def technique_params
    params.require(:technique).permit(:name)
  end
  
  def find_resource
    @technique = Technique.find(params[:id])
  end
  
end