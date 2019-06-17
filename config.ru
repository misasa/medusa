# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

is_stackprof = ENV['ENABLE_STACKPROF'].to_i.nonzero?
stackprof_mode = (ENV['STACKPROF_MODE'] || :object).to_sym
stackprof_interval = (ENV['STACKPROF_INTERVAL'] || 1000).to_i
stackprof_save_every = (ENV['STACKPROF_SAVE_EVERY'] || 5).to_i
stackprof_path = ENV['STACKPROF_PATH'] || 'tmp/stackprof/object_mode.dump'

use StackProf::Middleware,
  enabled: is_stackprof,
  mode: stackprof_mode,
  raw: true,
  interval: stackprof_interval,
  save_every: stackprof_save_every,
  path: stackprof_path  

if ENV['RAILS_RELATIVE_URL_ROOT']
  map ENV['RAILS_RELATIVE_URL_ROOT'] do
    run Rails.application
  end
else
  run Rails.application
end
