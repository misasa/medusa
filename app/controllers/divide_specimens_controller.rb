class DivideSpecimensController < ApplicationController
  respond_to :html, :xml, :json

  def edit
    @specimen = Specimen.find(params[:id]).decorate
    @specimen.divide_flg = true
    @specimen.children.build
    @divide = @specimen.build_divide
  end

  def update
    @specimen = Specimen.find(params[:id]).decorate
    @specimen.attributes = specimen_params
    @divide = Divide.new(divide_params)
    if @specimen.valid?
      ActiveRecord::Base.transaction do
        @divide.save!
        @specimen.divide_save(@divide)
      end
      redirect_to specimen_path(@specimen)
    else
      render :edit
    end
  end

  def loss
    @specimen = Specimen.find(params[:id]).decorate
    @specimen.attributes = specimen_params
    render json: { loss: "#{@specimen.divided_loss.to_s(:delimited)}(g)" }
  end

  private

  def specimen_params
    params.require(:specimen).permit(
      :quantity,
      :quantity_unit,
      children_attributes: [
        :name,
        :physical_form_id,
        :quantity,
        :quantity_unit
      ]
    )
  end

  def divide_params
    params.require(:divide).permit(
      :before_specimen_quantity_id,
      :divide_flg,
      :log
    )
  end
end
