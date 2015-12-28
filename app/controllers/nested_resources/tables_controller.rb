class NestedResources::TablesController < ApplicationController

  respond_to :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @tables = @parent.tables
    respond_with @tables
  end

  def create
    @table = Table.new(table_params)
    @parent.tables << @table if @table.save
    respond_with @table, location: adjust_url_by_requesting_tab(request.referer), action: "error"
  end

  def update
    @table = Table.find(params[:id])
    @parent.tables << @table
    respond_with @table, location: adjust_url_by_requesting_tab(request.referer)
  end

  def destroy
    @table = Table.find(params[:id])
    @parent.tables.delete(@table)
    @table.delete
    respond_with @table, location: adjust_url_by_requesting_tab(request.referer)
  end

  def link_by_global_id
    @table = Table.joins(:record_property).where(record_properties: {global_id: params[:global_id]}).readonly(false).first
    @parent.tables << @table if @table
    respond_with @table, location: adjust_url_by_requesting_tab(request.referer), action: "error"
  rescue
    duplicate_global_id
  end

  private

  def find_resource
    resource_name = params[:parent_resource]
    resource_class = resource_name.camelize.constantize
    @parent = resource_class.find(params["#{resource_name}_id"])
  end

  def table_params
    params.require(:table).permit(
      :bib_id,
      :caption,
      :measurement_category_id,
      :with_average,
      :with_place,
      :with_age,
      :age_unit,
      :description,
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

  def duplicate_global_id
    respond_to do |format|
      format.html { render "parts/duplicate_global_id", status: :unprocessable_entity }
      format.all { render nothing: true, status: :unprocessable_entity }
    end
  end

end
