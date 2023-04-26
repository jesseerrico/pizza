require 'sequel'

class App
    def call(env)
        headers = {
            'Content-Type' => 'text/html'
        }

        setup_db

        response = ['<h1>Hello World!</h1>']

        [200, headers, response]
    end

    private

    def setup_db
        database = Sequel.postgres('pizzadata', :user=>'postgres',:password=>'password',:host=>'localhost',:port=>5432,:max_connections=>10)

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
  end