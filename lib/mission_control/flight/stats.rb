module Flight
  class Stats
    attr_reader :speed, :burn_rate, :traveled_distance, :elapsed_time, :time_to_go

    def initialize(speed, burn_rate, traveled_distance, elapsed_time, time_to_go)
      @speed = speed
      @burn_rate = burn_rate
      @traveled_distance = traveled_distance
      @elapsed_time = elapsed_time
      @time_to_go = time_to_go
    end

    def ==(other)
      other.speed == @speed &&
      other.burn_rate == @burn_rate &&
      other.traveled_distance == @traveled_distance &&
      other.elapsed_time == @elapsed_time &&
      (other.time_to_go - @time_to_go).abs <= 0.0001
    end
  end
end
