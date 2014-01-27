class BibsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  def index
    @bibs = Bib.all
    respond_with @bibs
  end

  def show
    respond_with @bib
  end

  def new
    @bib = Bib.new
    respond_with @bib
  end

  def edit
    respond_with @bib
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
      :doi
    )
  end

  def find_resource
    @bib = Bib.find(params[:id])
  end

end
