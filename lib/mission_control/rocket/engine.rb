module Rocket
  class Engine
    attr_reader :avg_speed
    SPEED_FACTOR = 10

    def initialize(avg_speed, random_generator, stddev = 100)
      @rand_helper = random_generator
      @avg_speed = avg_speed
      @stddev = stddev

      @valid = false
      @next = 0
      @estabilization_time = time_for_reaching_average
    end

    def speed_at(elapsed_time)
      elapsed_time < @estabilization_time ? acceleration_speed_at(elapsed_time) : sustained_speed
    end

    private
    
    def sustained_speed
      if @valid
        @valid = false
        @next
      else
        @valid = true
        x, y = gaussian
        @next = y
        x
      end
    end

    def gaussian
      theta = 2 * Math::PI * @rand_helper.rand
      rho = Math.sqrt(-2 * Math.log(1 - @rand_helper.rand))
      scale = @stddev * rho
      x = @avg_speed + scale * Math.cos(theta)
      y = @avg_speed + scale * Math.sin(theta)
      [x, y]
    end

    # Based on quadractic acceleration
    def time_for_reaching_average
      (Math.sqrt(@avg_speed) / SPEED_FACTOR).round
    end

    def acceleration_speed_at(elapsed_time)
      (elapsed_time * SPEED_FACTOR)**2
    end
  end
end
