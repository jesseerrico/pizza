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
                PizzaAnalytics::find_streaks
            end

            resource :month_high do
                params do
                    requires :month_index, type:Integer, desc: "Month number 1-12"
                end
                route_param :month_index do
                    get do
                        PizzaAnalytics::month_high(params[:month_index])
                    end
                end
            end
        end
    end
end