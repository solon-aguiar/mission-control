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

    def ==(other_obj)
      other_obj.speed == @speed and
      other_obj.burn_rate == @burn_rate and
      other_obj.traveled_distance == @traveled_distance and
      other_obj.elapsed_time == @elapsed_time and
      (other_obj.time_to_go - @time_to_go).abs <= 0.0001
    end
  end
end