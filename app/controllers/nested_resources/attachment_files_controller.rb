class NestedResources::AttachmentFilesController < ApplicationController
  include TabParam

  respond_to :html, :xml, :json
  before_action :find_resource
  load_and_authorize_resource

  def index
    @attachment_files = @parent.attachment_files
    respond_with @attachment_files,methods: :path
  end

  def create
    @attachment_file = AttachmentFile.new(attachment_file_params)
    @parent.attachment_files << @attachment_file if @attachment_file.save
    respond_with @attachment_file, methods: :path, location: add_tab_param(request.referer), action: "error"      
  end

  def destroy
    @attachment_file = AttachmentFile.find(params[:id])
    @parent.attachment_files.delete(@attachment_file)
    respond_with @attachment_file, methods: :path, location: add_tab_param(request.referer)
  end

  def link_by_global_id
    @attachment_file = AttachmentFile.joins(:record_property).where(record_properties: {global_id: params[:global_id]}).readonly(false)
    @parent.attachment_files << @attachment_file
    respond_with @attachment_file, methods: :path, location: add_tab_param(request.referer)
  end

  private

  def find_resource
    resource_name = params[:parent_resource]
    resource_class = resource_name.camelize.constantize
    @parent = resource_class.find(params["#{resource_name}_id"])
  end

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

end
