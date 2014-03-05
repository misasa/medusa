class BibsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :upload]
  load_and_authorize_resource

  def index
    @search = Bib.readables(current_user).search(params[:q])
    @search.sorts = "updated_at DESC" if @search.sorts.empty?
    @bibs = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @bibs
  end

  def show
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
    @bib.update_attributes(bib_params)
    respond_with @bib
  end
  
  def destroy
    @bib.destroy
    respond_with @bib
  end

  def upload
    @bib = Bib.find(params[:id])
    @bib.attachment_files << AttachmentFile.new(data: params[:media])
    respond_with @bib
  end
  
  def property
    respond_with @bib, layout: !request.xhr?
  end

  private

  def bib_params
    params.require(:bib).permit(
      :entry_type,
      :abbreviation,
      :authorlist,
      :name,
      :journal,
      :year,
      :volume,
      :number,
      :pages,
      :month,
      :note,
      :key,
      :link_url,
      :doi,
      author_ids: [],
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
    @bib = Bib.find(params[:id]).decorate
  end

end
