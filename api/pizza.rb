require 'sequel'

module PizzaAnalytics
    class Pizza < Grape::API
        format :json

        resource :pizza do
            get :status do
                { status: 'pizzok'}
            end
            
            desc "See all pizzas"
            get do
                PizzaAnalytics::database[:pizzas].all
            end

            desc "Find a particular pizza"
            params do
                requires :id, type: Integer, desc: 'pizza ID'
            end
            route_param :id do
                get do
                    query = PizzaAnalytics::database[:pizzas].where(id: params[:id])
                    if(query.count == 0)
                        error!('404 Not Found', 404)
                    end
                    query.first
                end
            end

            desc "Create a new pizza"
            params do
                requires :name, type: String, desc: 'single topping on pizza'
            end
            post do
                # Add this pizza to the table unless it's already there
                query = PizzaAnalytics::database[:pizzas].where(name: params[:name])
                if(query.count > 0)
                    return query.select(:id)
                else
                    PizzaAnalytics::database[:pizzas].insert(name: params[:name])
                end
            end

            # curl -X PUT -H "Content-Type: application/json" -d '{"name":"Weird Pizza"}' localhost:9292/pizza/5
            desc "Update a pizza's name"
            params do
                requires :id, type: Integer, desc: "Pizza's ID"
                requires :name, type: String, desc: "Pizza's new name"
            end
            route_param :id do
                put do
                    PizzaAnalytics::database[:pizzas].where(id: params[:id]).update(name: params[:name])
                    PizzaAnalytics::database[:pizzas].where(id: params[:id]).first
                end
            end

            desc "Delete a pizza"
            params do
                requires :id, type: Integer, desc: 'pizza ID'
            end
            delete ':id' do
                PizzaAnalytics::database[:pizzas].where(id: params[:id]).delete
            end
        end
    end
end