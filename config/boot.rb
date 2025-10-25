ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

# Only require bundler/setup if not already loaded (prevents double-loading conflict)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE']) && !defined?(Bundler)
