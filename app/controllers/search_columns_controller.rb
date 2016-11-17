class SearchColumnsController < ApplicationController
  respond_to :html, :xml, :json
  load_and_authorize_resource
  skip_authorize_resource only: [:index, :update_order]

  def index
    @search_columns = SearchColumn.model_is(Specimen).user_is(current_user)
    respond_with @search_columns
  end

  def update_order
    respond_with SearchColumn.update_display(params[:display_types], current_user.id), :location => search_columns_path
  end

  def master_index
    @search_columns = SearchColumn.model_is(Specimen).master
    respond_with @search_columns, layout: "admin"
  end

  def master_update_order
    respond_with SearchColumn.update_display(params[:display_types], SearchColumn::MASTER_USER_ID), layout: "admin", :location => master_index_search_columns_path
  end
end
