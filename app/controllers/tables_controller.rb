class TablesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index]
  load_and_authorize_resource

  def index
    redirect_to bibs_path
  end

  def show
    respond_with @table
  end

  def edit
    respond_with @table, layout: !request.xhr?
  end

  def update
    @table.update_attributes(table_params)
    respond_with @table
  end

  def property
    respond_with @table, layout: !request.xhr?
  end

  def destroy
    @table.destroy
    respond_with @table
  end

  private

  def table_params
    params.require(:table).permit(
      :bib_id,
      :description,
      :measurement_category_id,
      :with_average,
      :with_place,
      record_property_attributes: [
        :global_id,
        :user_id,
        :group_id,
        :owner_readable,
        :owner_writable,
        :group_readable,
        :group_writable,
        :guest_readable,
        :guest_writable
      ]
    )
  end

  def find_resource
    @table = Table.find(params[:id]).decorate
  end

end
