class GroupsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :find_resource, only: [:show, :edit, :update]
  load_and_authorize_resource
  layout "admin"

  def index
    @search = Group.ransack(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @groups = @search.result.page(params[:page]).per(params[:per_page])
  end

  def show
    respond_with @group
  end

  def edit
    respond_with @group
  end

  def create
    @group = Group.new(group_params)
    @group.save
    respond_with(@group, location: groups_path)
  end

  def update
    @group.update(group_params)
    respond_with(@group, location: groups_path)
  end
  
  def destroy
    @group.destroy
    respond_with @group
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end

  def find_resource
    @group = Group.find(params[:id])
  end

end
