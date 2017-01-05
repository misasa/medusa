class DividesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :set_resource

  def edit
  end

  def update
    @divide.attributes = divide_params
    @divide.update if @divide.valid?
    respond_with @divide
  end

  def destroy
    @divide.destroy
    respond_with @divide, location: specimen_path(params[:specimen_id], tab: "quantity")
  end

  def loss
    @divide.attributes = divide_params
    if params[:manual]
      decimal_quantity = @divide.divided_loss
      json = {
        loss_quantity: Quantity.quantity(decimal_quantity).to_s,
        loss_quantity_unit: Quantity.quantity_unit(decimal_quantity),
        parent_quantity: @divide.parent_specimen_quantity.quantity.to_s,
        parent_quantity_unit: @divide.parent_specimen_quantity.quantity_unit
      }
    else
      decimal_quantity = @divide.divided_parent_quantity
      json = {
        loss_quantity: "0.0",
        loss_quantity_unit: "g",
        parent_quantity: Quantity.quantity(decimal_quantity).to_s,
        parent_quantity_unit: Quantity.quantity_unit(decimal_quantity)
      }
    end
    render json: json
  end

  def set_resource
    @divide = Divide.find(params[:id])
  end

  def divide_params
    params.require(:divide).permit(
      :updated_at,
      :log,
      specimen_quantities_attributes: [
        :id,
        :quantity_with_unit
      ]
    )
  end
end
