class DivideSpecimensController < ApplicationController
  respond_to :html, :xml, :json

  def edit
    @specimen = Specimen.find(params[:id]).decorate
    @specimen.children.build
  end

  def update
    @specimen = Specimen.find(params[:id]).decorate
    @specimen.attributes = parent_specimen_params
    if @specimen.valid?
      @specimen.divide_save
      redirect_to specimen_path(@specimen)
    else
      render :edit
    end
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
