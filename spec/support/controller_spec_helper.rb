module ControllerSpecHelper
  include Warden::Test::Helpers

  def sign_in(resource_or_scope, resource=nil)
    super
    User.current = resource || resource_or_scope
  end
end
