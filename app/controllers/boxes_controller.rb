class BoxesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :upload]
  load_and_authorize_resource

  def index
    @search = Box.readables(current_user).search(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @boxes = @search.result.includes(:box_type).page(params[:page]).per(params[:per_page])
    respond_with @boxes
  end

  def show
    respond_with @box
  end

  def edit
    respond_with @box, layout: !request.xhr?
  end

  def create
    @box = Box.new(box_params)
    @box.save
    respond_with @box
  end

  def update
    @box.update_attributes(box_params)
    respond_with @box
  end

  def destroy
    @box.destroy
    respond_with @box
  end

  def upload
    @box = Box.find(params[:id])
    @box.attachment_files << AttachmentFile.new(data: params[:data])
    respond_with @box
  end

  def family
    respond_with @box, layout: !request.xhr?
  end

  def picture
    respond_with @box, layout: !request.xhr?
  end

  def property
    respond_with @box, layout: !request.xhr?
  end

  private

  def box_params
    params.require(:box).permit(
      :name,
      :parent_id,
      :position,
      :path,
      :box_type_id,
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
    @box = Box.find(params[:id]).decorate
  end

end
