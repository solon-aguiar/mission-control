require_relative './simulated_params'

module Rocket
  class Rocket
    attr_reader :burn_rate, :speed

    def initialize(avg_burn_rate, avg_speed, random_speed_generator)
      @avg_burn_rate = avg_burn_rate
      @avg_speed = avg_speed

      @estabilization_time = (Math.sqrt(@avg_speed) / 10).round
      @random_speed_generator = random_speed_generator
    end

    def calculate_rates_for(elapsed_time)
      speed = elapsed_time >= @estabilization_time ? @random_speed_generator.rand : (elapsed_time * 10) ** 2
      burn_rate = (speed.to_f / @avg_speed) * @avg_burn_rate

      SimulatedParams.new(speed, burn_rate)
    end
  end
end