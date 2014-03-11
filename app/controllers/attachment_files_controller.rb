class AttachmentFilesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :upload, :download,:bundle_edit, :bundle_update]
  before_action :find_resources, only: [:bundle_edit, :bundle_update]
  load_and_authorize_resource

  def index
    @search = AttachmentFile.readables(current_user).search(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
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
      format.html { redirect_to ({action: :index}.merge(Marshal.restore(Base64.decode64(params[:page_params]))
))}
      format.json { render json: @attachment_file,methods: :path }
      format.xml { render xml: @attachment_file,methods: :path }
    end
  end

  def update
    @attachment_file.update_attributes(attachment_file_params)
    respond_with @attachment_file
  end

  def picture
    respond_with @attachment_file,methods: :path, layout: !request.xhr?
  end

  def property
    respond_with @attachment_file,methods: :path, layout: !request.xhr?
  end

  def destroy
    @attachment_file.destroy
    respond_with @attachment_file,methods: :path
  end

  def download
    @attachment_file = AttachmentFile.find(params[:id])
    send_file("#{Rails.root}/public#{@attachment_file.path}", filename: @attachment_file.data_file_name, type: @attachment_file.data_content_type)
  end

  def link_stone_by_global_id
    @attachment_file.stones << Stone.joins(:record_property).where(record_properties: {global_id: params[:global_id]})
    redirect_to :back
  end

  def link_bib_by_global_id
    @attachment_file.bibs << Bib.joins(:record_property).where(record_properties: {global_id: params[:global_id]})
    redirect_to :back
  end

  def bundle_edit
    respond_with @attachment_files
  end

  def bundle_update
    @attachment_files.each { |attachment_file| attachment_file.update_attributes(attachment_file_params.only_presence) }
    render :bundle_edit
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
      :user_id,
      :group_id,
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
  def find_resources
    @attachment_files = AttachmentFile.where(id: params[:ids])
  end

end
