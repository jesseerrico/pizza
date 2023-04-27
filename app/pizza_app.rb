require 'sequel'
require 'csv'

module PizzaAnalytics
    class App

        def self.instance
            @instance ||= Rack::Builder.new do
              use Rack::Cors do
                allow do
                  origins '*'
                  resource '*', headers: :any, methods: :get
                end
              end
      
              run PizzaAnalytics::App.new
            end.to_app
          end

        def call(env)
            @database = Sequel.postgres('pizzadata', :user=>'postgres',:password=>'password',:host=>'localhost',:port=>5432,:max_connections=>10)

            headers = {
                'Content-Type' => 'text/html'
            }

            response = PizzaAnalytics::API.call(env)

            response
        end
    end
end