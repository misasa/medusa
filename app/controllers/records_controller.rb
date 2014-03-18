class RecordsController < ApplicationController
  respond_to :html, :json, :xml
  before_action :find_resource, except: [:index]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    respond_with @records # TODO: jsonおよびxml表現ではどのような形式で欲しいのか？
  end

  def show
    respond_with @record do |format|
      format.html { redirect_to @record }
    end
  end

  def property
    respond_with @record.record_property
  end
  
  def destroy
    @record.destroy
    respond_with @record
  end

  private

  def find_resource
    @record = RecordProperty.find_by!(global_id: params[:id]).datum
    authorize!(params[:action], @record)
  end

  def record_not_found(e)
    render  'record_not_found', status: 404
  end

end
