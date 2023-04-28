require 'sequel'
require 'csv'

module PizzaAnalytics
    class App

        def self.instance
            @instance ||= Rack::Builder.new do
              use Rack::Cors do
                allow do
                  origins '*'
                  resource '*', headers: :any, methods: [:get, :post, :put]
                end
              end
      
              run PizzaAnalytics::App.new
            end.to_app
          end

        def call(env)
            headers = {
                'Content-Type' => 'text/html'
            }

            response = PizzaAnalytics::API.call(env)

            response
        end
    end

    # Database functions stored here as well

    def self.database
       @database ||= Sequel.sqlite
    end

    def self.setup_db
        # Create schema (if it's not already created)
        database.create_table? :people do
            primary_key :id
            String :name
        end

        database.create_table? :pizzas do
            primary_key :id
            String :name
        end

        database.create_table? :deliveries do
            primary_key :id
            foreign_key :person_id, :people
            foreign_key :pizza_id, :pizzas
            Date :date
        end
    end

    def self.add_seed_data_from_file
        PizzaAnalytics::setup_db
        output = ""
        table = CSV.parse(File.read("data.csv"), headers: true)

        for row in table do
            record_delivery(row["person"], row["meat-type"], row["date"])
        end
    end

    def self.record_delivery(person_name, pizza_name, date)
        # Add person to people table if necessary, get ID
        person_id = get_person_id(person_name)

        # Add pizza to pizza table if necessary, get ID
        pizza_id = get_pizza_id(pizza_name)

        # Add delivery to delivery table
        PizzaAnalytics::database[:deliveries].insert(person_id: person_id, pizza_id: pizza_id, date: date)
    end

    # Returns the ID of a pizza by name if it exists; creates it and returns that ID otherwise
    def self.get_pizza_id(name)
        query = PizzaAnalytics::database[:pizzas].where(name: name)
        if(query.count > 0)
            return query.select(:id)
        else
            PizzaAnalytics::database[:pizzas].insert(name: name)
        end
    end

    # Returns the ID of a person by name if they exist; creates them and returns that ID otherwise
    def self.get_person_id(name)
        query = PizzaAnalytics::database[:people].where(name: name)
        if(query.count > 0)
            return query.select(:id)
        else
            PizzaAnalytics::database[:people].insert(name: name)
        end
    end

    def self.get_pizza_name(id)
        query = database[:pizzas].where(id: id)
        if(query.count > 0)
            return query.first[:name]
        end
        raise "Pizza not found"
    end

    def self.get_person_name(id)
        query = database[:people].where(id: id)
        if(query.count > 0)
            return query.first[:name]
        end
        raise "Person not found"
    end
end