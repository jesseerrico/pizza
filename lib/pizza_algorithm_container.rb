class PizzaAlgorithmContainer
    def month_high(data)
        
        # Find pizzas per day
        pizzasPerDay = find_pizzas_per_day(data)

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

    def find_streaks(data)
        results = []

        # You can only have a streak with at least two days
        if(data.count > 1)
            # First count up pizzas per day, and store them in a hash
            pizzasPerDay = find_pizzas_per_day(data)

            currentStreak = []
            currentPizzaNumber = 0
            for date in pizzasPerDay.keys do 
                # If the number for this date is not higher than the current number, the current streak is over.
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

            # If you're done with the loop and the current streak has more than one day, push that one too
            if(currentStreak.length > 1)
                results.push(currentStreak)
            end

        end
        results
    end

    private

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