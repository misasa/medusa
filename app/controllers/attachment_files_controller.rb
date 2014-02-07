class AttachmentFilesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  def index
    @attachment_files = AttachmentFile.all
    respond_with @attachment_files
  end

  def show
    respond_with @attachment_file
  end

  def new
    @attachment_file = AttachmentFile.new
    respond_with @attachment_file
  end

  def edit
    respond_with @attachment_file
  end

  def create
    @attachment_file = AttachmentFile.new(attachment_file_params)
    @attachment_file.save
    respond_with @attachment_file
  end

  def update
    @attachment_file.update_attributes(attachment_file_params)
    respond_with @attachment_file
  end

  def destroy
    @attachment_file.destroy
    respond_with @attachment_file
  end

  private

  def attachment_file_params
    params.require(:attachment_file).permit(
      :name,
      :description,
      :md5hash,
      :data,
      :original_geometry,
      :affine_matrix
    )
  end

  def find_resource
    @attachment_file = AttachmentFile.find(params[:id])
  end

end
