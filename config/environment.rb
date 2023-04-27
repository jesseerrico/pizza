ENV['RACK_ENV'] ||= 'test'

require File.expand_path('application', __dir__)

DB_USERNAME="postgres"
DB_PASSWORD="password"