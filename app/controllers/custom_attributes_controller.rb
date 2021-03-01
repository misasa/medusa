class CustomAttributesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create]
  load_and_authorize_resource
  layout "admin"
  
  def index
    @search = CustomAttribute.ransack(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @custom_attributes = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @custom_attributes
  end
  
  def show
    respond_with @custom_attribute
  end
  
  def edit
    respond_with @custom_attribute
  end
  
  def create
    @custom_attribute = CustomAttribute.new(custom_attribute_params)
    @custom_attribute.save
    respond_with(@custom_attribute, location: custom_attributes_path)
  end
  
  def update
    @custom_attribute.update(custom_attribute_params)
    respond_with(@custom_attribute, location: custom_attributes_path)
  end
  
  def destroy
    @custom_attribute.destroy
    respond_with @custom_attribute
  end
  
  private
  
  def custom_attribute_params
    params.require(:custom_attribute).permit(:name, :sesar_name)
  end
  
  def find_resource
    @custom_attribute = CustomAttribute.find(params[:id])
  end
  
end
