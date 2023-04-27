require 'sequel'
require 'csv'

module PizzaAnalytics
    class Data < Grape::API
        format :json

        helpers do
            def database
                @database ||= Sequel.postgres('pizzadata', :user=>'postgres',:password=>'password',:host=>'localhost',:port=>5432,:max_connections=>10)
            end

            def setup_db
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

            # Returns the ID of a pizza by name if it exists; creates it and returns that ID otherwise
            def get_pizza_id(name)
                query = database[:pizzas].where(name: name)
                if(query.count > 0)
                    return query.select(:id)
                else
                    database[:pizzas].insert(name: name)
                end
            end

            # Returns the ID of a person by name if they exist; creates them and returns that ID otherwise
            def get_person_id(name)
                query = database[:people].where(name: name)
                if(query.count > 0)
                    return query.select(:id)
                else
                    database[:people].insert(name: name)
                end
            end
        end

        resource :data do
            get :setup_db do
                setup_db

                {status: "ok"}
            end

            get :add_seed_data_from_file do
                setup_db
                output = ""
                table = CSV.parse(File.read("data.csv"), headers: true)
    
                # Drop and recreate delivery table to start it from scratch (for testing purposes)
                database.drop_table?(:deliveries)
                database.create_table? :deliveries do
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
                    database[:deliveries].insert(person_id: person_id, pizza_id: pizza_id, date: row["date"])
                end
                {status: "ok"}
            end
        end
    end
end