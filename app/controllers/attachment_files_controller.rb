class AttachmentFilesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :upload]
  load_and_authorize_resource

  def index
    @search = AttachmentFile.readables(current_user).search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @attachment_files = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @attachment_files,methods: :path
  end

  def show
    respond_with @attachment_file,methods: :path
  end

  def edit
    respond_with @attachment_file,methods: :path, layout: !request.xhr?
  end

  def create
    @attachment_file = AttachmentFile.new(attachment_file_params)
    @attachment_file.save
    respond_with @attachment_file do |format|
      format.html { redirect_to action: :index,page: params[:page]}
      format.json { render json: @attachment_file,methods: :path }
      format.xml { render xml: @attachment_file,methods: :path }
    end
  end

  def update
    @attachment_file.update_attributes(attachment_file_params)
    respond_with @attachment_file
  end

  def destroy
    @attachment_file.destroy
    respond_with @attachment_file,methods: :path
  end

  private

  def attachment_file_params
    params.require(:attachment_file).permit(
      :name,
      :description,
      :md5hash,
      :data,
      :original_geometry,
      :affine_matrix,
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
    @attachment_file = AttachmentFile.find(params[:id]).decorate
  end

end
