Pizza Analytics Project
=======================

Launch this app by running `bundle install` and `bundle exec puma`. On launch, it should start up a memory DB and load data from `data.csv` into it without additional config necessary, and listen on port 9292.

Sample API commands
-------------------

```
curl localhost:9292/pizza # View all pizzas currently in DB
curl localhost:9292/pizza/1 # View pizza of ID 1 (by default this is pepperoni)
curl localhost:9292/pizza -d "name=plain" # Add a new pizza called "plain"
curl -X PUT -H "Content-Type: application/json" -d '{"name":"Weird Pizza"}' localhost:9292/pizza/2 # Change pizza of ID 2 to "Weird Pizza"

curl localhost:9292/person # View all people currently in DB
curl localhost:9292/person/1 # View person of ID 1 (by default this is Albert)
curl localhost:9292/person -d "name=Jesse" # Add a new person named Jesse
curl -X PUT -H "Content-Type: application/json" -d '{"name":"Jon"}' localhost:9292/person/2 # Change person of ID 2's name to Jon

curl localhost:9292/delivery # View all pizza consumptions on file (I thought of them as deliveries)
curl localhost:9292/delivery -d "person_name=Jesse&pizza_name=BBQ&date=2015-01-08" # Record a new delivery, adding the new person and pizza if necessary
curl localhost:9292/delivery/find_streaks # View all "streaks" of increasing pizza consumption on file
curl localhost:9292/delivery/month_high/1 # View the date of highest pizza consumption among all January dates
```

Tests
-----

As instructed, this project includes a few test cases of the month_high and find_streaks algorithms. Run them with `bundle exec rspec`.
