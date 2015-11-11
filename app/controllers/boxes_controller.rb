class BoxesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :bundle_edit, :bundle_update, :download_card, :download_bundle_card, :download_label, :download_bundle_label]
  before_action :find_resources, only: [:bundle_edit, :bundle_update, :download_bundle_card, :download_bundle_label]
  load_and_authorize_resource

  def index
    @search = Box.readables(current_user).search(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @boxes = @search.result.includes(:box_type).page(params[:page]).per(params[:per_page])
    respond_with @boxes
  end

  def show
    @contents_search = @diff_search = Path.search
    @contents_search.sorts = "path ASC"
    @contents = Path.none
    @src_date = Date.yesterday.strftime("%Y%m%d")
    @dst_date = Date.today.strftime("%Y%m%d")
    @diff_search = Path.diff(@box, @src_date, @dst_date).search(params[:q])
    @diff_search.sorts = "path ASC"
    @diff = @diff_search.result
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

  def family
    respond_with @box, layout: !request.xhr?
  end

  def picture
    respond_with @box, layout: !request.xhr?
  end

  def property
    respond_with @box, layout: !request.xhr?
  end

  def contents
    @contents_search = Path.contents_of(@box).search(params[:q])
    @contents_search.sorts = "path ASC" if @contents_search.sorts.empty?
    @contents = @contents_search.result.includes(datum: :record_property)
    @contents = @contents.current if @contents_search.conditions.empty?
    respond_with @contents, layout: !request.xhr?
  end

  def diff
    @src_date = params[:src]
    @dst_date = params[:dst]
    @diff_search = Path.diff(@box, @src_date, @dst_date).search(params[:q])
    @diff_search.sorts = "path ASC" if @diff_search.sorts.empty?
    @diff = @diff_search.result
    respond_with @diff, layout: !request.xhr?
  end

  def bundle_edit
    respond_with @boxes
  end

  def bundle_update
    @boxes.each { |box| box.update_attributes(box_params.only_presence) }
    render :bundle_edit
  end

  def download_card
    report = Box.find(params[:id]).build_card
    send_data(report.generate, filename: "box.pdf", type: "application/pdf")
  end

  def download_bundle_card
    method = (params[:a4] == "true") ? :build_a_four : :build_cards
    report = Box.send(method, @boxes)
    send_data(report.generate, filename: "boxes.pdf", type: "application/pdf")
  end

  def download_label
    box = Box.find(params[:id])
    send_data(box.build_label, filename: "box_#{box.id}.csv", type: "text/csv")
  end

  def download_bundle_label
    label = Box.build_bundle_label(@boxes)
    send_data(label, filename: "boxes.csv", type: "text/csv")
  end
  
  private

  def box_params
    params.require(:box).permit(
      :name,
      :parent_global_id,
      :parent_id,
      :position,
      :path,
      :box_type_id,
      :tag_list,
      :user_id,
      :group_id,
      :published,
      record_property_attributes: [
        :global_id,
        :user_id,
        :group_id,
        :owner_readable,
        :owner_writable,
        :group_readable,
        :group_writable,
        :guest_readable,
        :guest_writable
      ]
    )
  end

  def find_resource
    @box = Box.find(params[:id]).decorate
  end

  def find_resources
    @boxes = Box.where(id: params[:ids])
  end

end
