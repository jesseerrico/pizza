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

    # Helper functions, put here instead of directly into APIs so they can be more easily unit-tested

    def self.database
        @database ||= Sequel.postgres('pizzadata', :user=>DB_USERNAME,:password=>DB_PASSWORD,:host=>'localhost',:port=>5432,:max_connections=>10)
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

    # Given a set of results from the delivery table, this code will create a hash mapping dates to the number of pizzas eaten that day
    def self.find_pizzas_per_day(deliveries)
        pizzasPerDay = Hash.new
        for row in deliveries do
            date = row[:date]
            if(pizzasPerDay.key?(date))
                pizzasPerDay[date] = pizzasPerDay[date] + 1
            else
                pizzasPerDay[date] = 1
            end
        end

        return pizzasPerDay
    end

    def self.find_streaks
        results = []
        # Sort by date. That's important.
        query = PizzaAnalytics::database[:deliveries].order(:date).select(:date)
        
        # You can only have a streak with at least two days
        if(query.count > 1)
            # First count up pizzas per day, and store them in a hash
            pizzasPerDay = PizzaAnalytics::find_pizzas_per_day(query)

            currentStreak = []
            currentPizzaNumber = 0
            for date in pizzasPerDay.keys do 
                # If the number for this date is not higher than the current number, the streak is over.
                if pizzasPerDay[date] <= currentPizzaNumber
                    # If it's longer than one day, add it to the results.
                    if (currentStreak.length > 1)
                        results.push(currentStreak)
                    end

                    # Start the streak over
                    currentStreak = []
                end

                # Store the current pizza number and add today to the streak
                currentStreak.push(date)
                currentPizzaNumber = pizzasPerDay[date]
            end

        end
        results
    end

    def self.month_high(month_index)
        if month_index < 1 || month_index > 12
            raise "Month " + month_index.to_s + " doesn't exist"
        end
        
        # Find all deliveries in that month (I am interpreting this problem to include dates of that month in all years)
        # This requires a pure SQL query so you can call extract
        query = PizzaAnalytics::database['select * from deliveries where extract(month from date) = ?', month_index]
        
        # Find pizzas per day
        pizzasPerDay = PizzaAnalytics::find_pizzas_per_day(query)

        currentHighestPizzaNumber = 0
        result = ""
        for date in pizzasPerDay.keys do
            if pizzasPerDay[date] > currentHighestPizzaNumber
                result = date.to_s
                currentHighestPizzaNumber = pizzasPerDay[date]
            end
        end

        {pizzaPeakDay: result}
    end
end