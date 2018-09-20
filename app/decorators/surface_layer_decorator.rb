class SurfaceLayerDecorator < Draper::Decorator
  delegate_all

  def published
    false
  end
end
