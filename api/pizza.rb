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
            
            params do
                requires :id, type: Integer, desc: 'pizza ID'
            end
            route_param :id do
                get do
                    database = Sequel.postgres('pizzadata', :user=>'postgres',:password=>'password',:host=>'localhost',:port=>5432,:max_connections=>10)
                    result = database[:pizzas].where(id: params[:id]).first
                    {id: params[:id], name: result[:name]}
                end
            end
        end
    end
end