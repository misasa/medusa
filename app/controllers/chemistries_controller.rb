class ChemistriesController < ApplicationController
  respond_to :html, :xml, :json
  load_and_authorize_resource

  def edit
    respond_with @chemistry, layout: !request.xhr?
  end

  def update
    @chemistry.update_attributes(chemistry_params)
    respond_with @chemistry, location: analysis_path(@chemistry.analysis)
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

end
