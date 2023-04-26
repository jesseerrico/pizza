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

            # setup_db
            # output = add_seed_data_from_file

            # response = ['<h1>Data setup stuff complete!</h1>',
            #             output]

            #[200, headers, response]
            response
        end

        private

        def setup_db
            # Create schema (if it's not already created)
            @database.create_table? :people do
                primary_key :id
                String :name
            end

            @database.create_table? :pizzas do
                primary_key :id
                String :name
            end

            @database.create_table? :deliveries do
                primary_key :id
                foreign_key :person_id, :people
                foreign_key :pizza_id, :pizzas
                Date :date
            end
        end

        # def person_exists?(name)
        #     @database[:people].where(name: name).count > 0
        # end

        # Returns the ID of a person by name if they exist; creates them and returns that ID otherwise
        def get_person_id(name)
            query = @database[:people].where(name: name)
            if(query.count > 0)
                return query.select(:id)
            else
                @database[:people].insert(name: name)
            end
        end

        # def pizza_exists?(name)
        #     @database[:pizzas].where(name: name).count > 0
        # end

        def get_pizza_id(name)
            query = @database[:pizzas].where(name: name)
            if(query.count > 0)
                return query.select(:id)
            else
                @database[:pizzas].insert(name: name)
            end
        end

        # For the purposes of this exercise, consider a delivery to a given person at a given time to be unique
        # (since I'm going to be testing a lot and don't want to dupe data too much)
        # def delivery_exists?(person_id, date)
        #     @database[:deliveries].where(person_id: person_id, date: date).count > 0
        # end

        def add_seed_data_from_file
            output = ""
            table = CSV.parse(File.read("data.csv"), headers: true)

            # Drop and recreate delivery table to start it from scratch (for testing purposes)
            #@database[:deliveries].delete
            @database.drop_table?(:deliveries)
            @database.create_table? :deliveries do
                primary_key :id
                foreign_key :person_id, :people
                foreign_key :pizza_id, :pizzas
                Date :date
            end

            for row in table do
                # Add person to people table if necessary, get ID
                person_id = get_person_id(row["person"])

                # Add pizza to pizza table if necessary, get ID
                pizza_id = get_pizza_id(row["meat-type"])

                # Add delivery to delivery table
                # if !delivery_exists?(person_id, row["date"])
                @database[:deliveries].insert(person_id: person_id, pizza_id: pizza_id, date: row["date"])
                # end

                output += row["person"] +", "+row["meat-type"]+", "+row["date"] + "\n"
            end
            output
        end
    end
end