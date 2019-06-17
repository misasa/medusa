Medusa::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  #config.action_controller.perform_caching = false
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  
  # Bullet
  #config.after_initialize do
  #  Bullet.enable = true
  #  Bullet.alert = false
  #  Bullet.bullet_logger = true
  #  Bullet.console = false
  #  Bullet.rails_logger = true
  #  Bullet.add_footer = false
  #end
  
  is_stackprof = ENV['ENABLE_STACKPROF'].to_i.nonzero?
  stackprof_mode = (ENV['STACKPROF_MODE'] || :wall).to_sym
  stackprof_interval = (ENV['STACKPROF_INTERVAL'] || 1000).to_i
  stackprof_save_every = (ENV['STACKPROF_SAVE_EVERY'] || 5).to_i
  stackprof_path = ENV['STACKPROF_PATH'] || 'tmp/stackprof/wall_mode.dump'

  config.middleware.use StackProf::Middleware,
    enabled: is_stackprof,
    mode: stackprof_mode,
    raw: true,
    interval: stackprof_interval,
    save_every: stackprof_save_every,
    path: stackprof_path  

  #RackLineprf
  config.middleware.use Rack::Lineprof
end
