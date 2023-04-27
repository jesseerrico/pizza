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
                pizzasPerDay = Hash.new
                # You can only have a streak with at least two days
                if(query.count > 1)
                    # First count up pizzas per day, and store them in a hash
                    for row in query do
                        date = row[:date]
                        if(pizzasPerDay.key?(date))
                            pizzasPerDay[date] = pizzasPerDay[date] + 1
                        else
                            pizzasPerDay[date] = 1
                        end
                    end
                    
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
        end
    end
end