require "pizza_algorithm_container"

describe PizzaAlgorithmContainer do
    
    # In order to limit the number of records returned from data, month filtering is done in the data step. As such, it's handled before testing
    # (since as per assignment instructions DB config stuff isn't handled here). This does limit the efficacy of these tests, but I decided to value
    # data efficiency in this tradeoff.
    describe ".month_high" do
        context "Given empty data" do
            it "returns empty string" do
                expect(PizzaAlgorithmContainer.new.month_high([])).to eq({:pizzaPeakDay=>""})
            end
        end
        context "Given exactly one pizza date" do
            it "returns that value" do
                data = [{:monthIndex=>"01", date: "2015-01-02"}]
                expect(PizzaAlgorithmContainer.new.month_high(data)).to eq({:pizzaPeakDay=>"2015-01-02"})
            end
        end
        context "Given a normal set of data" do
            it "returns expected value" do
                data = [{:monthIndex=>"01", date: "2015-01-01"},
                        {:monthIndex=>"01", date: "2015-01-01"},
                        {:monthIndex=>"01", date: "2015-01-01"},
                        {:monthIndex=>"01", date: "2015-01-03"},
                        {:monthIndex=>"01", date: "2015-01-03"},
                        {:monthIndex=>"01", date: "2015-01-04"},
                        {:monthIndex=>"01", date: "2015-01-04"}]
                expect(PizzaAlgorithmContainer.new.month_high(data)).to eq({:pizzaPeakDay=>"2015-01-01"})
            end
        end
    end

    # Note that, similarly to above, sorting is handled on the data layer, meaning that on the algorithmic layer we can expect to be given sorted data
    describe ".find_streaks" do
        context "Given empty data" do
            it "returns empty set" do
                expect(PizzaAlgorithmContainer.new.find_streaks([])).to eq([])
            end
        end
        context "Given data with no streaks whatsoever" do
            it "returns empty set when given data for one day" do
                data = [
                    {:date=>"2015-01-01"},
                    {:date=>"2015-01-01"},
                    {:date=>"2015-01-01"},
                    {:date=>"2015-01-01"},
                    {:date=>"2015-01-01"},
                    {:date=>"2015-01-01"},
                    {:date=>"2015-01-01"},
                    {:date=>"2015-01-01"},
                ]
                expect(PizzaAlgorithmContainer.new.find_streaks(data)).to eq([])
            end
            it "returns empty set when given several days with one pizza each" do 
                data = [
                    {:date=>"2015-01-01"},
                    {:date=>"2015-01-02"},
                    {:date=>"2015-01-03"},
                    {:date=>"2015-01-04"},
                    {:date=>"2015-01-05"},
                    {:date=>"2015-01-06"},
                    {:date=>"2015-01-07"},
                    {:date=>"2015-01-08"},
                ]
                expect(PizzaAlgorithmContainer.new.find_streaks(data)).to eq([])
            end
        end
        context "Given some valid data" do
            it "finds streaks from consecutive days and stops when appropriate" do
                data = [
                    {:date=>"2015-01-01"},
                    {:date=>"2015-01-02"},
                    {:date=>"2015-01-02"},
                    {:date=>"2015-01-03"},
                    {:date=>"2015-01-03"},
                    {:date=>"2015-01-03"},
                    {:date=>"2015-01-04"},
                    {:date=>"2015-01-04"},
                    {:date=>"2015-01-05"},
                    {:date=>"2015-01-05"},
                    {:date=>"2015-01-05"}, # <-- end on a streak here
                ]
                expect(PizzaAlgorithmContainer.new.find_streaks(data)).to eq([["2015-01-01","2015-01-02","2015-01-03"],["2015-01-04", "2015-01-05"]])
            end
            it "Ignores skipped days when nobody ate any pizza" do
                data = [
                    {:date=>"2015-01-01"},
                    {:date=>"2015-02-01"},
                    {:date=>"2015-02-01"},
                    {:date=>"2015-03-03"},
                    {:date=>"2015-03-03"},
                    {:date=>"2015-03-03"},
                    {:date=>"2015-04-04"},
                    {:date=>"2015-04-04"},
                    {:date=>"2015-04-08"},
                    {:date=>"2015-04-08"},
                    {:date=>"2015-04-08"},
                    {:date=>"2015-04-09"}, # <-- do not end on a streak here
                ]
                expect(PizzaAlgorithmContainer.new.find_streaks(data)).to eq([["2015-01-01","2015-02-01","2015-03-03"],["2015-04-04", "2015-04-08"]])
            end
        end
    end
end