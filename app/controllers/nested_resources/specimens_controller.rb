class NestedResources::SpecimensController < ApplicationController

  respond_to  :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @specimens = @parent.send(params[:association_name])
    respond_with @specimens
  end

  def create
    @specimen = Specimen.new(specimen_params)
    ActiveRecord::Base.transaction do
    	 succeed = @parent.send(params[:association_name]) << @specimen if @specimen.save
      raise ActiveRecord::Rollback unless succeed
    end
    respond_with @specimen, location: adjust_url_by_requesting_tab(request.referer), action: "error" 
  end

  def update
    @specimen = Specimen.find(params[:id])
    @parent.send(params[:association_name]) << @specimen
    respond_with @specimen
  end

  def destroy
    @specimen = Specimen.find(params[:id])
    @parent.send(params[:association_name]).delete(@specimen)
    respond_with @specimen, location: adjust_url_by_requesting_tab(request.referer)
  end

  def link_by_global_id
    @specimen = Specimen.joins(:record_property).where(record_properties: {global_id: params[:global_id]}).readonly(false).first
    @parent.send(params[:association_name]) << @specimen if @specimen
    respond_with @specimen, location: adjust_url_by_requesting_tab(request.referer), action: "error"
  rescue
    duplicate_global_id
  end
  
  def inventory
    @specimen = Specimen.find(params[:id])
    @specimen.update_attributes(box_id: params[:box_id])
    @specimen.paths.current.first.update_attribute(:checked_at, Time.now) if @specimen.paths.current.first
    respond_with @specimen
  end

  private

  def specimen_params
    params.require(:specimen).permit(
      :name,
      :physical_form_id,
      :classification_id,
      :quantity,
      :quantity_unit,
      :tag_list,
      :parent_id,
      :box_id,
      :place_id,
      :description,
      :igsn,
      :age_min,
      :age_max,
      :age_unit,
      :size,
      :size_unit,
      :collector,
      :collector_detail,
      :collected_at,
      :collection_dateprecision,
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
      format.all { render nothing: true, status: :unprocessable_entity }
    end
  end

end
