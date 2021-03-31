module ToggleColumn
  module Helpers
    class Toggler
      def initialize(template, options={})
        @template = template
        @options = options
        @param = template.params[:toggle_column]
      end

      def expand?
        @param == "expand"
      end

      def fold?
        !expand?
      end

      def icon
        @template.content_tag :span, nil, class: "fas #{icon_name}"
      end

      def url_for(toggle_column)
        @template.url_for @template.params.permit!.merge(toggle_column: toggle_column)
      end

      def to_s
        @template.link_to icon, url_for(toggled_param), @options
      end

      private

      def icon_name
        expand? ? "fa-chevron-left" : "fa-chevron-right"
      end

      def toggled_param
        expand? ? "fold" : "expand"
      end
    end
  end
end
