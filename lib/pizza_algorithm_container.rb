class PizzaAlgorithmContainer
    def month_high(data)
        
        # Find pizzas per day
        pizzasPerDay = PizzaAnalytics::find_pizzas_per_day(data)

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
            pizzasPerDay = PizzaAnalytics::find_pizzas_per_day(data)

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