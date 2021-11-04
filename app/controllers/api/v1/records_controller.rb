# -*- coding: utf-8 -*-
class Api::V1::RecordsController < Api::ApplicationController
  before_action :find_resource, except: [:index]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def show
    render json: @record.record_property.to_json(methods: [:datum_attributes])
  end

  private

  def find_resource
    @record = RecordProperty.find_by!(global_id: params[:id]).datum
    authorize!(params[:action].to_sym, @record)
  end

  def record_not_found(e)
    render json: {body: nil, status: :not_found }
  end

end
