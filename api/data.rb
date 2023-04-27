require 'sequel'
require 'csv'

module PizzaAnalytics
    class Data < Grape::API
        format :json

        resource :data do
            get :setup_db do
                PizzaAnalytics::setup_db

                {status: "ok"}
            end

            get :add_seed_data_from_file do
                
                {status: "ok"}
            end
        end
    end
end