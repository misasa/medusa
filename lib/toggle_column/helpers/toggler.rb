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
        @template.content_tag :span, nil, class: "glyphicon #{icon_name}"
      end

      def url_for(toggle_column)
        @template.url_for @template.params.merge(toggle_column: toggle_column)
      end

      def to_s
        @template.link_to icon, url_for(toggled_param), @options
      end

      private

      def icon_name
        expand? ? "glyphicon-chevron-left" : "glyphicon-chevron-right"
      end

      def toggled_param
        expand? ? "fold" : "expand"
      end
    end
  end
end
