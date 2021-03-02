class PhysicalFormsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  before_action :read_yml, only: [:index, :edit]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = PhysicalForm.ransack(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @physical_forms = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @physical_forms
  end

  def show
    respond_with @physical_form
  end

  def edit
    respond_with @physical_form
  end

  def create
    @physical_form = PhysicalForm.new(physical_form_params)
    @physical_form.save
    respond_with @physical_form
  end

  def update
    @physical_form.update(physical_form_params)
    respond_with(@physical_form, location: physical_forms_path)
  end

  def destroy
    @physical_form.destroy
    respond_with @physical_form
  end

  private

  def physical_form_params
    params.require(:physical_form).permit(
      :name,
      :sesar_sample_type,
      :description
    )
  end

  def find_resource
    @physical_form = PhysicalForm.find(params[:id])
  end

  def read_yml
    @sample_types = YAML.load(File.read("#{Rails.root}/config/sample_type.yml"))["sample_type"]
  end
end
