module PizzaAnalytics
    class API < Grape::API
        format :json
        mount ::PizzaAnalytics::Pizza
    end
end