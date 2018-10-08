require_relative './stats'
require_relative './summary'
require_relative '../unit'

module Flight
  class Flight
    attr_reader :finished, :exploded
    alias :finished? :finished
    alias :exploded? :exploded

    def initialize(rocket, planned_distance, sleep_interval = 1, explosion_distance = 0)
      raise ArgumentError.new('Invalid explosion_distance') if explosion_distance > 0 and explosion_distance > planned_distance
      @rocket = rocket

      @planned_distance = planned_distance
      @explosion_distance = explosion_distance
      @sleep_interval = sleep_interval

      @traveled_distance = 0
      @burnt_fuel = 0
      @total_time = 0

      @exploded = false
      @finished = false
    end

    def launch!(&callback)
      start_time = Time.now
      previous_time = start_time

      loop do
        if should_explode
          @exploded = true
          break
        end

        current_time = Time.now
        interval_elapsed = current_time - previous_time
        previous_time = current_time

        @total_time += interval_elapsed

        speed, burn_rate = @rocket.calculate_rates_for(@total_time)
        @traveled_distance += Unit.km_per_hour_to_km_per_se(speed * interval_elapsed)
        @burnt_fuel += Unit.liters_per_minute_to_liters_per_sec(burn_rate)

        break if @traveled_distance >= @planned_distance
        yield(Stats.new(speed, burn_rate, @traveled_distance, Unit.se_to_ms(@total_time), Unit.se_to_ms(calculate_time_left(speed)))) if block_given?

        sleep(@sleep_interval)
      end

      @finished = true
    end

    def summary
      raise ArgumentError.new('No summary for incomplete flight') unless @finished

      Summary.new(@traveled_distance, @burnt_fuel, Unit.se_to_ms(@total_time))
    end

    private

    def calculate_time_left(speed)
      (@planned_distance - @traveled_distance).to_f / Unit.km_per_hour_to_km_per_se(speed)
    end

    def should_explode
      @explosion_distance > 0 and @traveled_distance >= @explosion_distance
    end
  end
end
