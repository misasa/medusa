source 'https://rubygems.org'
source 'http://dream.misasa.okayama-u.ac.jp/rubygems/'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '6.1.2.1'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.1'

#If the Sprockets higher than the following version, Sprockets::Railtie::ManifestNeededError will occur when the app is started.
gem 'sprockets', '3.7.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 4.1.18'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'spinjs-rails'
gem "best_in_place", git: "https://github.com/mmotherwell/best_in_place"

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
#gem 'active_model_serializers'

gem 'lazy_high_charts'
gem 'histogram'
gem 'narray'
group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'devise', github: 'heartcombo/devise'
gem 'omniauth', '2.0.3'
gem 'omniauth-google-oauth2'
gem 'omniauth-shibboleth'
gem 'omniauth-rails_csrf_protection'
gem 'cancancan'
gem 'kaminari'
gem 'draper'
gem 'paperclip'
gem 'barby'
gem 'rqrcode'
gem 'chunky_png'
gem 'color_code'
gem 'alchemist', github: 'halogenandtoast/alchemist', ref: '5c086daffa1baf962b6b0e304234535ba964b86a'
gem 'geonames'
gem 'rubyzip'
#gem 'oai'
gem 'comma'
gem 'acts-as-taggable-on'
gem 'exception_notification'
gem 'settingslogic'
#gem 'acts_as_mappable', git: 'git@devel.misasa.okayama-u.ac.jp:gems/actsasmappable.git'
gem 'acts_as_mappable', '0.1.5'
#gem 'with_recursive', git: 'git@devel.misasa.okayama-u.ac.jp:gems/withrecursive.git'
gem 'with_recursive', '0.0.7'
gem 'thinreports', '0.7.7'
gem 'bootstrap-sass'
gem 'ransack'
gem 'whenever', require: false
gem 'acts_as_list'
gem 'builder'
gem 'activeresource'
gem 'geocoder'
#gem 'dimensions'
gem 'sidekiq', '~> 4.2'
gem 'sidekiq-failures'
gem 'sidekiq-history'
gem 'sidekiq-status'
gem 'terrapin'
gem 'bigdecimal', '1.3.5'
gem 'responders'
gem 'webpacker', '5.2.1'
group :development, :test do
  gem 'rack-lineprof'
  gem 'stackprof'
  gem 'stackprof-webnav'
  gem 'rack-mini-profiler', require: false
  gem 'bullet'
  gem 'rak'
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 4.0.2'
  gem 'rails-controller-testing'
  gem 'spring'
  gem 'guard-rspec', require: false
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler'
  gem 'capistrano-sidekiq'
  gem 'capistrano-yarn'
  gem 'capistrano-db-tasks', require: false
  gem 'webmock'
end

group :test do
  gem 'capybara', '>= 2.2.0'
  gem 'poltergeist', '>= 1.5.0'
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'ci_reporter'
  gem 'factory_bot_rails'
  gem 'timecop'
end
