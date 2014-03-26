class AttachingsController < ApplicationController
  respond_to  :html, :xml, :json
  load_and_authorize_resource

  def move_to_top
    @attaching.move_to_top
    respond_with @attaching, location: adjust_url_by_requesting_tab(request.referer)
  end

end
