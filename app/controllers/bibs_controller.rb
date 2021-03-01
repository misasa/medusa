class BibsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :bundle_edit, :bundle_update, :download_bundle_card, :download_label, :download_bundle_label, :download_to_tex]
  before_action :find_resources, only: [:bundle_edit, :bundle_update, :download_bundle_card, :download_bundle_label, :download_to_tex]
  load_and_authorize_resource

  def index
    @search = Bib.includes(bib_authors: :author).readables(current_user).order("bib_authors.priority").ransack(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @bibs = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @bibs
  end

  def show
    respond_with @bib
  end

  def specimens_detail
    respond_with @bib
  end

  def edit
    respond_with @bib, layout: !request.xhr?
  end

  def create
    @bib = Bib.new(bib_params)
    @bib.save
    respond_with @bib
  end

  def update
    @bib.update(bib_params)
    respond_with @bib
  end

  def publish
    #@bib.publish!
    PublishWorker.perform_async(@bib.global_id)
    respond_with @bib
  end
  
  def destroy
    @bib.destroy
    respond_with @bib
  end

  def family
    respond_with @bib, layout: !request.xhr?
  end

  def picture
    respond_with @bib, layout: !request.xhr?
  end
  
  def map
    respond_with @bib, layout: !request.xhr?
  end

  def property
    respond_with @bib, layout: !request.xhr?
  end

  def bundle_edit
    respond_with @bibs
  end

  def bundle_update
    @bibs.each { |bib| bib.update(bib_params.only_presence) }
    render :bundle_edit
  end

  def download_bundle_card
    method = (params[:a4] == "true") ? :build_a_four : :build_cards
    report = Bib.send(method, @bibs)
    send_data(report.generate, filename: "bibs.pdf", type: "application/pdf")
  end

  def download_label
    bib = Bib.find(params[:id])
    send_data(bib.build_label, filename: "bib_#{bib.id}.label", type: "text/label")
  end

  def download_bundle_label
    label = Bib.build_bundle_label(@bibs)
    send_data(label, filename: "bibs.label", type: "text/label")
  end
  
  def download_to_tex
    tex = Bib.build_bundle_tex(@bibs)
    send_data(tex, filename: "bibs.bib", type: "text")
  end

  private

  def bib_params
    params.require(:bib).permit(
      :entry_type,
      :abbreviation,
      :name,
      :journal,
      :year,
      :volume,
      :number,
      :pages,
      :month,
      :abstract,
      :summary,
      :note,
      :key,
      :link_url,
      :doi,
      :user_id,
      :group_id,
      :published,
      author_ids: [],
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
      ],
      bib_authors_attributes: [
        :id,
        :priority
      ]
    )
  end

  def find_resource
    @bib = Bib.includes({places: [:record_property]}, {analyses: [:record_property, :device, :chemistries]}, {tables: {analyses: [:device, :record_property, :chemistries]}}, {specimens: [:tags, :record_property, :attachment_files, :classification, :physical_form, :specimen_custom_attributes, {place: [:record_property]}, {box: [:record_property]}, {analyses: [:device, :record_property, :chemistries]}]}).find(params[:id]).decorate
  end

  def find_resources
    @bibs = Bib.where(id: params[:ids])
  end

end
