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
        end
    end
end