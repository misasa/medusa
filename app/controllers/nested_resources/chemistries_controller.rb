class NestedResources::ChemistriesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create]
  before_action :find_resources, only: [:create, :update, :destroy]
  load_and_authorize_resource

  def index
    @chemistries = Analysis.find(params[:analysis_id]).chemistries
    respond_with @chemistries
  end

  def create
    @chemistry = Chemistry.new(chemistry_params)
    @parent.chemistries << @chemistry
    respond_with @chemistry, location: request.referer
  end

  def update
    @chemistry = Chemistry.find(params[:id])
    @parent.chemistries << @chemistry
    respond_with @chemistry, location: request.referer
  end

  def destroy
    @chemistry.destroy
    @parent.chemistries.delete(@chemistry)
    respond_with @chemistry, location: request.referer
  end

  private
 def chemistry_params
    params.require(:chemistry).permit(
      :measurement_item_id,
      :info,
      :value,
      :label,
      :description,
      :uncertainty,
      :unit_id,
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
    @chemistry = Chemistry.find(params[:id]).decorate
  end

  def find_resources
    @parent = Analysis.find(params[:analysis_id])
  end

end
