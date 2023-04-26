require 'sequel'

module PizzaAnalytics
    class Pizza < Grape::API
        format :json

        helpers do
            def database
                @database ||= Sequel.postgres('pizzadata', :user=>'postgres',:password=>'password',:host=>'localhost',:port=>5432,:max_connections=>10)
            end
        end

        resource :pizza do
            get :status do
                { status: 'pizzok'}
            end
            
            desc "Find a particular pizza"
            params do
                requires :id, type: Integer, desc: 'pizza ID'
            end
            route_param :id do
                get do
                    query = database[:pizzas].where(id: params[:id])
                    if(query.count == 0)
                        error!('404 Not Found', 404)
                    end
                    result = query.first
                    {id: params[:id], name: result[:name]}
                end
            end

            desc "Create a new pizza"
            params do
                requires :name, type: String, desc: 'single topping on pizza'
            end
            post do
                # Add this pizza to the table unless it's already there
                query = database[:pizzas].where(name: params[:name])
                if(query.count > 0)
                    return query.select(:id)
                else
                    database[:pizzas].insert(name: params[:name])
                end
            end
        end
    end
end