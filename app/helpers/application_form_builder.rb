class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  def file_browse_field(method, options = {})
    self.multipart = true
    @template.content_tag(:label, class:"input-group-btn") do
      @template.concat(
        @template.content_tag(:span, class:"btn btn-primary", title:"choose file") do
          @template.concat("Browse...")
          @template.concat(@template.file_field(@object_name, method, objectify_options(options.merge({class:"browse", style:"display:none"}))))
        end
      )
    end
  end
end
