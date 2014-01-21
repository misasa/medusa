class GroupsController < ApplicationController
  layout "admin"

  def index
    @search = Group.search(params[:q])
    @search.sorts = "updated_at ASC" if @search.sorts.empty?
    @groups = @search.result.page(params[:page]).per(params[:per_page])
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      redirect_to groups_path
    else
      # TODO: When validation error ...
      redirect_to groups_path
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    if @group.update_attributes(group_params)
      redirect_to groups_path
    else
      # TODO: When validation error ...
      render :edit
    end
  end

  def destroy
    Group.find(params[:id]).destroy
    redirect_to groups_path
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end

end
