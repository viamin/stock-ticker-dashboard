source "https://rubygems.org"

ruby "2.7.4"

# Pin bigdecimal to a version compatible with Ruby 2.7
gem "bigdecimal", "~> 1.4.4"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.4", ">= 7.1.4.2"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
# gem "sprockets-rails"
gem "propshaft"
# Use sqlite3 as the database for Active Record
gem "sqlite3", "<= 1.4"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails", "2.0.30"
# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mswin mswin64 mingw x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri ], require: "debug/prelude"


  gem "faker" # https://github.com/faker-ruby/faker

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem "capistrano", "3.11.2", require: false
  gem "capistrano-bundler", "~> 1.6", require: false
  gem "capistrano-rails", "1.4.0", require: false
  gem "ed25519", "~> 1.3"
  gem "bcrypt_pbkdf", "~> 1.1"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  gem "annotate" # https://github.com/ctran/annotate_models

  # gem "kamal", "~> 2.2", require: false # https://github.com/basecamp/kamal

  gem "erb_lint", require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end

gem "chartkick", github: "viamin/chartkick", branch: "ruby27" # https://github.com/ankane/chartkick

gem "friendly_id" # https://github.com/norman/friendly_id


gem "groupdate" # https://github.com/ankane/groupdate

gem "faraday"

gem "mission_control-jobs", "~> 0.3.3" # https://github.com/rails/mission_control-jobs
