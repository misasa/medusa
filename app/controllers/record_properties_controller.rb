class RecordPropertiesController < ApplicationController
  respond_to :html, :json, :xml
  before_action :find_resource

  def show
    respond_with @record_property
  end

  def update
    @record_property.update_attributes(record_property_params)
    respond_with @record_property
  end

  private

  def find_resource
    resource_name = params[:parent_resource]
    resource_class = resource_name.camelize.constantize
    parent_resource = resource_class.find(params["#{resource_name}_id"])
    @record_property = parent_resource.record_property
  end

  def record_property_params
    params.require(:record_property).permit(
      :datum_id,
      :datum_type,
      :user_id,
      :group_id,
      :global_id,
      :published,
      :owner_writable,
      :group_readable,
      :group_writable,
      :guest_readable,
      :guest_writable
    )
  end

end
