class ActionController::Parameters
  def only_presence
    each_with_object({}) do |pair, dst|
      key, value = pair
      value = value.only_presence if value.is_a?(ActionController::Parameters)
      dst[key] = value if value.present?
    end
  end
end
