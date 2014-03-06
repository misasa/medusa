class AttachingsController < ApplicationController
  load_and_authorize_resource

  def move_to_top
    @attaching.move_to_top
    redirect_to controller: find_controller,action: :show,id: @attaching.attachable_id
  end

  def destroy
    @attaching.destroy
    redirect_to controller: find_controller,action: :show,id: @attaching.attachable_id
  end

private
  def find_controller
    @attaching.attachable_type.underscore.pluralize
  end

end
