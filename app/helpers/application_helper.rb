module ApplicationHelper

  def navbar_path(controller_name="")
    system_modes = [
      "system_preferences",
      "users",
      "groups",
      "classifications",
      "physical_forms",
      "box_types",
      "measurement_items",
      "measurement_categories"
    ]
    system_modes.include?(controller_name) ? "layouts/navbar_system" : "layouts/navbar_default"
  end

end
