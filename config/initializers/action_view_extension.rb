module DefaultIdAppendToFormWith
  def form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
    html_options = options[:html] ||= {}
    if model && html_options[:id].nil?
      as = options[:as]
      namespace = options[:namespace]
      action = model.persisted? ? :edit : :new
      html_options[:id] = (as ? [namespace, action, as] : [namespace, dom_id(model, action)]).compact.join("_").presence
    end 
    super(model: model, scope: scope, url: url, format: format, **options, &block)
  end
end

ActiveSupport.on_load(:action_view) do
  ::ActionView::Base.prepend DefaultIdAppendToFormWith
end
  