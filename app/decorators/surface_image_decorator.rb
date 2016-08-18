class SurfaceImageDecorator < Draper::Decorator
  include Rails.application.routes.url_helpers	
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def target_path
    surface_image_path(surface, self.image, script_name: Rails.application.config.relative_url_root)
  end
end
