class ClassificationsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  before_action :read_yml, only: [:index, :edit, :create, :update]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = Classification.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @classifications = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @classifications
  end

  def show
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
    update_params = classification_params
    if @classification.check_classification(update_params["sesar_material"], update_params["sesar_classification"])
      @classification.update_attributes(update_params)
    end
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
      :rgt,
      :sesar_material,
      :sesar_classification
    )
  end

  def find_resource
    @classification = Classification.find(params[:id])
  end
  
  def read_yml
    @material = YAML.load(File.read("#{Rails.root}/config/material_classification.yml"))["material"]
    @sesar_classification = []
  end
end
