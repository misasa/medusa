class AuthorsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, except: [:index, :create, :upload]
  load_and_authorize_resource
  layout "admin"
  
  def index
    @search = Author.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @authors = @search.result.page(params[:page]).per(params[:per_page])
    respond_with @authors
  end
  
  def show
    respond_with @author
  end
  
  def edit
    respond_with @author
  end
  
  def create
    @author = Author.new(author_params)
    @author.save
    respond_with(@author, location: authors_path)
  end
  
  def update
    @author.update_attributes(author_params)
    respond_with(@author, location: authors_path)
  end
  
  private
  
  def author_params
    params.require(:author).permit(:name)
  end
  
  def find_resource
    @author = Author.find(params[:id])
  end
  
end