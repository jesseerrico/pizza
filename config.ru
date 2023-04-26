# require 'rack'
# require_relative './application.rb'

# run App.new

# require File.expand_path('../application', __FILE__)

#run Application

# Pizza::API.compile!
# run Pizza::API

require File.expand_path('config/environment', __dir__)

run PizzaAnalytics::App.instance