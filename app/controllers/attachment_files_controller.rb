class AttachmentFilesController < ApplicationController
  respond_to :html, :xml, :json, :svg
  before_action :find_resource, except: [:index, :create, :download, :bundle_edit, :bundle_update]
  before_action :find_resources, only: [:bundle_edit, :bundle_update]
  load_and_authorize_resource

  def index
    @search = AttachmentFile.readables(current_user).search(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @attachment_files = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @attachment_files
  end

  def show
    respond_with @attachment_file
  end

  def calibrate
    respond_with @attachment_file, layout: !request.xhr?
  end

  def edit_affine_matrix
    respond_with @attachment_file, layout: !request.xhr?
  end

  def edit_corners
    respond_with @attachment_file, layout: !request.xhr?
  end

  def edit
    logger.info("in edit")
    logger.info(request)    
    respond_with @attachment_file, layout: !request.xhr?
  end

  def create
    @attachment_file = AttachmentFile.new(attachment_file_params)
    @attachment_file.save
    respond_with @attachment_file do |format|
      if @attachment_file.new_record?
        format.html { render action: "error"}
      else
        format.html { redirect_to ({action: :index}.merge(Marshal.restore(Base64.decode64(params[:page_params]))))}
      end
      format.json { render json: @attachment_file }
      format.js { render :success }
      format.xml { render xml: @attachment_file }
    end
  end

  def update
    @attachment_file.update_attributes(attachment_file_params)
    respond_with @attachment_file, location: adjust_url_by_requesting_tab(request.referer), action: "error"
  end

  def update_affine_matrix
    m = params["affine_matrix"]
    if m.any?{|w| w.blank?}
      respond_with @attachment_file do |format|
        format.json { render status: 400}
      end
    else
      @attachment_file.update_attributes({affine_matrix: m.map(&:to_f)})
      #respond_with @attachment_file
      respond_with @attachment_file do |format|
        format.json { render json: @attachment_file }
      end
    end
  end

  def update_corners
    m = params["corners_on_world"]
    a = []
    flag = true
    ["lu", "ru", "rb", "lb"].each do |key|
      if m[key].any?{|w| w.blank? }
        flag = false
        break
      end
      a << m[key].map(&:to_f)  
    end
    if flag
      @attachment_file.update_attributes({corners_on_world: a})
#      respond_with @attachment_file
      respond_with @attachment_file do |format|
        format.json { render json: @attachment_file }
      end
    else
      respond_with @attachment_file do |format|
        format.json { render status: 204}
      end
    end
  end

  def property
    respond_with @attachment_file, layout: !request.xhr?
  end

  def picture 
    respond_with @attachment_file, layout: !request.xhr?
  end

  def destroy
    @attachment_file.destroy
    respond_with @attachment_file
  end

  def download
    @attachment_file = AttachmentFile.find(params[:id])
    send_file(@attachment_file.data.path, filename: @attachment_file.data_file_name, type: @attachment_file.data_content_type)
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
      :affine_matrix_in_string,
      :user_id,
      :group_id,
      :published,
      record_property_attributes: [
        :id,
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
        :lost
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
