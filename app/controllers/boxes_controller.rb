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
    @button_action_selection_items = ["snapshot"]
    duration_numbers = [1, 2]
    ["difference from", "integration from"].each do |prefix|
      ["day", "week", "month", "year"].each do |str|
          duration_numbers.each do |num| 
            @button_action_selection_items << "#{prefix} #{num} #{str.pluralize(num)} ago"
          end
      end
    end
    @button_action_selection_items = @button_action_selection_items.map{|item| [item, item]}

    if !(params[:dst_date].blank?)
      @dst_date = params[:dst_date]
      if m = /difference from (\d*) (.*) ago/.match(params[:button_action])
        ddate = Date.strptime(@dst_date, "%Y-%m-%d")
        case m[2]
        when "day", "days"
          sdate = ddate.days_ago(m[1].to_i)
        when "week", "weeks"
          sdate = ddate.weeks_ago(m[1].to_i)
        when "month", "months"
          sdate = ddate.months_ago(m[1].to_i)
        when "year", "years"
          sdate = ddate.years_ago(m[1].to_i)
        else
          sdate = ddate.days_ago(1)
        end
        @src_date = sdate.strftime("%Y-%m-%d")
        @contents_search = Path.diff(@box, @src_date, @dst_date).search(params[:q])
        @contents_search.sorts = "path ASC" if @contents_search.sorts.empty?
        @contents = @contents_search.result
        @contents = @contents.page(params[:page]).per(params[:per_page])
      else
        params[:q] = {} unless params[:q]
        if m = /integration from (\d*) (.*) ago/.match(params[:button_action])
          ddate = Date.strptime(@dst_date, "%Y-%m-%d")
          case m[2]
          when "day", "days"
            sdate = ddate.days_ago(m[1].to_i)
          when "week", "weeks"
            sdate = ddate.weeks_ago(m[1].to_i)
          when "month", "months"
            sdate = ddate.months_ago(m[1].to_i)
          when "year", "years"
            sdate = ddate.years_ago(m[1].to_i)
          else
            sdate = ddate.days_ago(1)
          end
          params[:q][:brought_out_at_gteq] = sdate.strftime("%Y-%m-%d")
          params[:q][:brought_in_at_lteq_end_of_day] = @dst_date
        else
          params[:q][:exists_at] = @dst_date
        end
        @contents_search = Path.contents_of(@box).search(params[:q])
        @contents_search.sorts = "path ASC" if @contents_search.sorts.empty?
        @contents = @contents_search.result.includes(datum: :record_property)
        @contents = @contents.current if @contents_search.conditions.empty?
        @contents = @contents.page(params[:page]).per(params[:per_page])
      end
    else
      @dst_date = Date.today.strftime("%Y-%m-%d")
      @contents_search = Path.search(params[:q])
      @contents_search.sorts = "path ASC"
      @contents = Path.none
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

end
