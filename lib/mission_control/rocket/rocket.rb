module Rocket
  class Rocket
    def initialize(avg_burn_rate, engine)
      @avg_burn_rate = avg_burn_rate
      @engine = engine
    end

    def calculate_rates_for(elapsed_time)
      speed = @engine.speed_at(elapsed_time)
      burn_rate = (speed.to_f / @engine.avg_speed) * @avg_burn_rate

      [speed, burn_rate]
    end
  end
end
