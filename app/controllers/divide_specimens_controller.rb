class DivideSpecimensController < ApplicationController
  respond_to :json
  before_action :set_resource

  def update
    @specimen.divide_save if @specimen.valid?(:divide)
    respond_with @specimen
  end

  def loss
    if params[:manual]
      decimal_quantity = @specimen.divided_loss
      json = {
        loss_quantity: Quantity.quantity(decimal_quantity).to_s,
        loss_quantity_unit: Quantity.quantity_unit(decimal_quantity),
        parent_quantity: @specimen.quantity.to_s,
        parent_quantity_unit: @specimen.quantity_unit
      }
      render json: json
    else
      decimal_quantity = @specimen.divided_parent_quantity
      if decimal_quantity > 0
        json = {
          loss_quantity: "0.0",
          loss_quantity_unit: "g",
          parent_quantity: Quantity.quantity(decimal_quantity).to_s,
          parent_quantity_unit: Quantity.quantity_unit(decimal_quantity)
        }
        render json: json
      else
        render json: nil
        #render status: :bad_request
      end
    end
  end

  private

  def parent_specimen_params
    params.require(:specimen).permit(
      :quantity,
      :quantity_unit,
      :quantity_with_unit,
      :comment,
      children_attributes: [
        :name,
        :physical_form_id,
        :quantity,
        :quantity_unit,
        :quantity_with_unit        
      ]
    )
  end

  def set_resource
    @specimen = Specimen.find(params[:id])
    @specimen.attributes = parent_specimen_params
  end
end
