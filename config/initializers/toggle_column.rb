require File.expand_path("../../../lib/toggle_column/helpers/toggler.rb", __FILE__)
require File.expand_path("../../../lib/toggle_column/action_view_extension.rb", __FILE__)

ActiveSupport.on_load(:action_view) do
  ::ActionView::Base.send :include, ToggleColumn::ActionViewExtension
end
