module ToggleColumn
  module ActionViewExtension
    def toggle_column_link(options={})
      toggler = ToggleColumn::Helpers::Toggler.new(self, options)
      toggler.to_s
    end

    def th_if_expand(content_or_options_with_block=nil, options=nil, &block)
      content_tag_if_expand(:th, content_or_options_with_block, options, &block)
    end

    def td_if_expand(content_or_options_with_block=nil, options=nil, &block)
      content_tag_if_expand(:td, content_or_options_with_block, options, &block)
    end

    def content_tag_if_expand(name, content_or_options_with_block=nil, options=nil, &block)
      toggler = ToggleColumn::Helpers::Toggler.new(self)
      content_tag(name, content_or_options_with_block, options, &block) if toggler.expand?
    end
  end
end
