require 'sequel'

module PizzaAnalytics
    class Delivery < Grape::API
        format :json

        resource :delivery do
            get :status do
                {status: 'deliverok'}
            end

            desc "See all deliveries (or consumptions)"
            get do
                results = []
                query = PizzaAnalytics::database[:deliveries].all

                for row in query do
                    results.push({"person": PizzaAnalytics::get_person_name(row[:person_id]), "meat-type": PizzaAnalytics::get_pizza_name(row[:pizza_id]), "date": row[:date]})
                end

                results
            end

            desc "Find all streaks of increased pizza consumption"
            get :find_streaks do
                
                # Do database stuff here so that data can be fed into the algorithm for unit tests
                # Sort by date. That's important.
                query = PizzaAnalytics::database[:deliveries].order(:date).select(:date)
                PizzaAlgorithmContainer.new.find_streaks(query.to_a)
            end

            resource :month_high do
                params do
                    requires :month_index, type:Integer, desc: "Month number 1-12"
                end
                route_param :month_index do
                    get do
                        month_index = params[:month_index]
                        if month_index < 1 || month_index > 12
                            raise "Month " + month_index.to_s + " doesn't exist"
                        end

                        # Do database stuff here so that data can be fed into the algorithm for unit tests
                        # A two-digit string representation is necessary for SQL reasons
                        month_index_string = format('%02d', month_index)
                        query = PizzaAnalytics::database["select strftime('%m', date) as monthIndex, date from deliveries where monthIndex = ?", month_index_string]
                        PizzaAlgorithmContainer.new.month_high(query.to_a)
                    end
                end
            end
        end
    end
end