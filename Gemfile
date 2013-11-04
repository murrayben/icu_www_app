source "https://rubygems.org"

gem "rails", "4.0.0"
gem "mysql2", git: "https://github.com/brianmario/mysql2.git", :ref => "ecb675b5494f4347817547e7fcb5441f4378cffc"
gem "haml-rails"
gem "sass-rails", "~> 4.0.0"
gem "uglifier", ">= 1.3.0"
gem "jquery-rails"
gem "turbolinks"
gem "cancan", "~> 1.6"
gem "redis"
gem "therubyracer", "0.11.4", platforms: :ruby # 0.12.0 requires requires gcc 4.4 to compile v8 (ratalacha has 4.1)
gem "icu_name"
gem "icu_utils"
gem "validates_timeliness", "~> 3.0"

group :development do
  gem "capistrano"
  gem "capistrano-maintenance"
  gem "wirble"
end

group :development, :test do
  gem "rspec-rails"
  gem "capybara"
  gem "selenium-webdriver"
  gem "factory_girl_rails", "~> 4.0"
  gem "launchy"
  gem "faker"
  gem "database_cleaner"
end
