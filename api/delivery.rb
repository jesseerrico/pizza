require 'sequel'

module PizzaAnalytics
    class Delivery < Grape::API
        format :json

        helpers do
            def database
                @database ||= Sequel.postgres('pizzadata', :user=>'postgres',:password=>'password',:host=>'localhost',:port=>5432,:max_connections=>10)
            end
        
            def get_pizza_name(id)
                query = database[:pizzas].where(id: id)
                if(query.count > 0)
                    return query.first[:name]
                end
                error!('404 Not Found', 404)
            end
    
            def get_person_name(id)
                query = database[:people].where(id: id)
                if(query.count > 0)
                    return query.first[:name]
                end
                error!('404 Not Found', 404)
            end

            # Given a set of results from the delivery table, this code will create a hash mapping dates to the number of pizzas eaten that day
            def find_pizzas_per_day(deliveries)
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
        end

        resource :delivery do
            get :status do
                {status: 'deliverok'}
            end

            desc "See all deliveries (or consumptions)"
            get do
                results = []
                query = database[:deliveries].all

                for row in query do
                    results.push({"person": get_person_name(row[:person_id]), "meat-type": get_pizza_name(row[:pizza_id]), "date": row[:date]})
                end

                results
            end

            desc "Find all streaks of increased pizza consumption"
            get :find_streaks do
                results = []
                # Sort by date. That's important.
                query = database[:deliveries].order(:date).select(:date)
                #pizzasPerDay = Hash.new
                # You can only have a streak with at least two days
                if(query.count > 1)
                    # First count up pizzas per day, and store them in a hash
                    pizzasPerDay = find_pizzas_per_day(query)

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

            resource :month_high do
                params do
                    requires :month_index, type:Integer, desc: "Month number 1-12"
                end
                route_param :month_index do
                    get do
                        if params[:month_index] < 1 || params[:month_index] > 12
                            error!('404 not found', 404)
                        end
                        
                        # Find all deliveries in that month (I am interpreting this problem to include dates of that month in all years)
                        # This requires a pure SQL query so you can call extract
                        query = database['select * from deliveries where extract(month from date) = ?', params[:month_index]]
                        
                        # Find pizzas per day
                        pizzasPerDay = find_pizzas_per_day(query)

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
            end
        end
    end
end