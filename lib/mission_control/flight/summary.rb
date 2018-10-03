module Flight
  class Summary
    attr_reader :travelled_distance, :fuel_burnt, :total_time

    def initialize(travelled_distance, fuel_burnt, total_time)
      @travelled_distance = travelled_distance
      @fuel_burnt = fuel_burnt
      @total_time = total_time
    end
  end
end