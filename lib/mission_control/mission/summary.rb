module Mission
  class Summary
    attr_reader :all_plans, :flight
    
    def initialize(all_plans, flight)
      @all_plans = all_plans
      @flight = flight
    end
  end
end
