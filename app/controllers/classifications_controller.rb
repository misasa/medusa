class ClassificationsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = Classification.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @classifications = @search.result.page(params[:page]).per(params[:per_page])
  end

  def show
    respond_with @classification
  end

  def new
    @classification = Classification.new
    respond_with @classification
  end

  def edit
    respond_with @classification
  end

  def create
    @classification = Classification.new(classification_params)
    @classification.save
    respond_with @classification
  end

  def update
    @classification.update_attributes(classification_params)
    respond_with(@classification, location: classifications_path)

  end

  def destroy
    @classification.destroy
    respond_with @classification
  end

  private

  def classification_params
    params.require(:classification).permit(
      :name,
      :full_name,
      :description,
      :parent_id,
      :lft,
      :rgt
    )
  end

  def find_resource
    @classification = Classification.find(params[:id])
  end

end
