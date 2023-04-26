require 'sequel'

module PizzaAnalytics
    class Person < Grape::API
        format :json

        helpers do
            def database
                @database ||= Sequel.postgres('pizzadata', :user=>'postgres',:password=>'password',:host=>'localhost',:port=>5432,:max_connections=>10)
            end
        end

        resource :person do
            get :status do
                { status: 'persok'}
            end
            
            desc 'See all people'
            get do
                database[:people].all
            end

            desc 'Get information on a person'
            params do
                requires :id, type: Integer, desc: 'person ID'
            end
            route_param :id do
                get do
                    query = database[:people].where(id: params[:id])
                    if(query.count == 0)
                        error!('404 Not Found', 404)
                    end
                    query.first
                end
            end

            desc "Create a new person"
            params do
                requires :name, type: String, desc: "Person's name"
            end
            post do
                # Add this pizza to the table unless it's already there
                query = database[:people].where(name: params[:name])
                if(query.count > 0)
                    return query.select(:id)
                else
                    database[:people].insert(name: params[:name])
                end
            end

            # curl -X PUT -H "Content-Type: application/json" -d '{"name":"Jesse"}' localhost:9292/person/5
            desc "Update a person's name"
            params do
                requires :id, type: Integer, desc: "Person's ID"
                requires :name, type: String, desc: "Person's new name"
            end
            route_param :id do
                put do
                    database[:people].where(id: params[:id]).update(name: params[:name])
                    database[:people].where(id: params[:id]).first
                end
            end

            desc "Delete a person"
            params do
                requires :id, type: Integer, desc: "Person's ID"
            end
            delete ':id' do
                database[:people].where(id: params[:id]).delete
            end
        end
    end
end