class DevicesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create]
  load_and_authorize_resource
  layout "admin"
  
  def index
    @search = Device.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    #@devices = @search.result.page(params[:page]).per(params[:per_page])
    @devices = @search.result
    respond_with @devices
  end
  
  def show
    respond_with @device
  end
  
  def edit
    respond_with @device
  end
  
  def create
    @device = Device.new(device_params)
    @device.save
    respond_with(@device, location: devices_path)
  end
  
  def update
    @device.update_attributes(device_params)
    respond_with(@device, location: devices_path)
  end
  
  def destroy
    @device.destroy
    respond_with @device
  end
  
  private
  
  def device_params
    params.require(:device).permit(:name)
  end
  
  def find_resource
    @device = Device.find(params[:id])
  end
  
end