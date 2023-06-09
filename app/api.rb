module PizzaAnalytics
    class API < Grape::API
        format :json
        mount ::PizzaAnalytics::Pizza
        mount ::PizzaAnalytics::Person
        mount ::PizzaAnalytics::Delivery
        mount ::PizzaAnalytics::Data
    end
end