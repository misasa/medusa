class BoxesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :show, :bundle_edit, :bundle_update, :download_card, :download_bundle_card, :download_label, :download_bundle_label]
  before_action :find_resources, only: [:bundle_edit, :bundle_update, :download_bundle_card, :download_bundle_label]
  load_and_authorize_resource

  def index
    @search = Box.includes(:parent).readables(current_user).search(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @boxes = @search.result.includes(:box_type).page(params[:page]).per(params[:per_page])
    respond_with @boxes
  end

  def show
    # @contents_search = Path.search(exists_at: Date.today.strftime("%Y%m%d"))
    # @contents_search.sorts = "path ASC"
    # @contents = Path.none
    # @contents = @contents.page(1).per(10)
    #if params[:q]
    separator = "-----"
    @button_action_selection_items = ["", "recent", "snapshot", separator]
    duration_numbers = [1]
    ["in/out from", "integ from", "diff from" ].each do |prefix|
      ["day", "week", "month", "year"].each do |str|
          duration_numbers.each do |num| 
            @button_action_selection_items << "#{prefix} #{num} #{str.pluralize(num)} ago"
          end
      end
    end
    @button_action_selection_items = @button_action_selection_items.map{|item| [item, item]}

    params[:q] = {} unless params[:q]

    if !(params[:dst_date].blank?)
      @dst_date = params[:dst_date]
    else
      @dst_date = Date.today.strftime("%Y-%m-%d")
    end

    if !(params[:src_date].blank?)
      @src_date = params[:src_date]
    else
      ddate = Date.strptime(@dst_date, "%Y-%m-%d")
      if m = /from (\d*) (.*) ago/.match(params[:button_action])
        sdate = convert_date(ddate, m[1], m[2])
      else
        oldest = Path.order(brought_in_at: :asc).first
        if oldest
          sdate = oldest.brought_in_at
        else
          sdate = convert_date(ddate, "10", "years")
        end
      end
      @src_date = sdate.strftime("%Y-%m-%d")
    end

    if Time.zone.parse(@dst_date).today?
      dst_date_time = Time.zone.now
    else
      dst_date_time = Time.zone.parse(@dst_date).end_of_day
    end

    default_sorts = "path ASC"
    if params[:button_action].blank? || params[:button_action] == separator
      @contents_search = Path.search(params[:q])
      @contents_search.sorts = "path ASC"
      @contents = Path.none
      @contents = @contents.page(params[:page]).per(params[:per_page])
    else
      case params[:button_action]
      when /diff/
        @contents_search = Path.diff(@box, @src_date, dst_date_time).search(params[:q])
      when /integ/
        @contents_search = Path.integ(@box, @src_date, dst_date_time).search(params[:q])
      when /snapshot/
        @contents_search = Path.snapshot(@box, dst_date_time).search(params[:q])
      else
        # in/out
        @contents_search = Path.change(@box, @src_date, dst_date_time).search(params[:q])
        default_sorts = ["brought_at DESC", "sign ASC"]
      end
      @contents_search.sorts = default_sorts if @contents_search.sorts.empty?
      @contents = @contents_search.result
      #@contents = @contents.current if @contents_search.conditions.empty?
      @contents = @contents.page(params[:page]).per(params[:per_page])
    end
    @box = Box.includes(children: [:record_property, :box_type], specimens: [:record_property, :analyses, :physical_form]).find(params[:id]).decorate
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
      :description,
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

  def convert_date(date, value, unit)
    case unit
    when "day", "days"
      date.days_ago(value.to_i)
    when "week", "weeks"
      date.weeks_ago(value.to_i)
    when "month", "months"
      date.months_ago(value.to_i)
    when "year", "years"
      date.years_ago(value.to_i)
    else
      date.days_ago(1)
    end
  end

end
