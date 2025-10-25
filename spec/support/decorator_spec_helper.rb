module DecoratorSpecHelper
  # Provides a view context helper 'h' for decorator specs
  # This is needed because decorators often need to generate HTML forms/links
  # and need access to Rails view helpers like form_for, link_to, etc.
  
  def h
    @helper ||= Class.new do
      include ActionView::Helpers::FormHelper
      include ActionView::Helpers::FormOptionsHelper  # For select, select_tag, etc
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TextHelper
      include ActionView::Context
      include Rails.application.routes.url_helpers
      
      # Default URL options (required by url_helpers)
      def default_url_options
        { host: 'test.host' }
      end
      
      # Mock controller (required by form_for)
      def controller
        @controller ||= OpenStruct.new(
          controller_name: 'test',
          action_name: 'index',
          request: OpenStruct.new(
            fullpath: '/test',
            path_parameters: {}
          )
        )
      end
      
      # Protect against forgery (required by form_for)
      def protect_against_forgery?
        false
      end
      
      # Form authenticity token (required by form_for)
      def form_authenticity_token
        'test_token'
      end
      
      # Output buffer (required for rendering)
      def output_buffer
        @output_buffer ||= ActiveSupport::SafeBuffer.new
      end
      
      def output_buffer=(buffer)
        @output_buffer = buffer
      end
    end.new
  end
end
