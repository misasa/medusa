class TablesController < ApplicationController
  respond_to :html, :xml, :json, :csv, :pml
  before_action :find_resource, except: [:index]
  load_and_authorize_resource

  def index
    redirect_to bibs_path
  end

  def display
    respond_with @table, layout: !request.xhr?
  end

  def show
    respond_with @table do |format|
      format.csv { send_data render_to_string, filename: "#{@table.caption}.csv", type: :csv }
      format.pml { render pml: [@table]}
    end
  end

  def edit
    respond_with @table, layout: !request.xhr?
  end

  def update
    @table.update(table_params)
    respond_with @table
  end

  def publish
    #@table.publish!
    PublishWorker.perform_async(@table.global_id)
    respond_with @table
  end

  def refresh
    #@table.publish!
    TableRefreshWorker.perform_async(@table.id)
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
      :bib_global_id,
      :caption,
      :measurement_category_id,
      :with_average,
      :with_place,
      :with_age,
      :with_error,
      :age_unit,
      :age_scale,
      :description,
      record_property_attributes: [
        :id,
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
        :lost
      ],
      table_specimens_attributes: [
        :id,
        :position
      ],
      table_analyses_attributes: [
        :id,
        :priority
      ]
    )
  end

  def find_resource
    @table = Table.find(params[:id]).decorate
    @table.refresh
  end

end
