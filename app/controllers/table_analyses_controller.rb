class TableAnalysesController < ApplicationController
  respond_to :html, :json
  before_action :find_resource
  load_and_authorize_resource


  def show
    respond_with @table_analysis
  end

  def update
    @table.update_attributes(table_params)
    respond_with @table
  end

  def destroy
    @table_analysis.destroy
    respond_with @table
  end
  
  private

  def find_resource
    @table = Table.find(params[:table_id]).decorate
    @table.refresh
    @table_analysis = TableAnalysis.find(params[:id])
  end

end
