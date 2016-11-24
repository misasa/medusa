class DivideSpecimensController < ApplicationController
  respond_to :json

  def update
    @specimen = Specimen.find(params[:id])
    @specimen.attributes = parent_specimen_params
    @specimen.divide_save if @specimen.valid?(:divide)
    respond_with @specimen
  end

  def loss
    @specimen = Specimen.find(params[:id]).decorate
    @specimen.attributes = parent_specimen_params
    render json: { loss: "#{@specimen.divided_loss.to_s(:delimited)}(g)" }
  end

  private

  def parent_specimen_params
    params.require(:specimen).permit(
      :quantity,
      :quantity_unit,
      :comment,
      children_attributes: [
        :name,
        :physical_form_id,
        :quantity,
        :quantity_unit
      ]
    )
  end
end
