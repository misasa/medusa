class AttachingsController < ApplicationController
  respond_to  :html, :xml, :json
  load_and_authorize_resource

  def move_to_top
    @attaching.move_to_top
    respond_with @attaching, location: request.referer
  end

end
