require_relative './stats'
require_relative './summary'

module Flight
  class Flight
    attr_reader :finished, :exploded
    alias :finished? :finished
    alias :exploded? :exploded

    @@KM_PER_HOUR_TO_SEC_RATIO = 60 * 60
    @@L_PER_MI_TO_SEC_RATIO = 60

    def initialize(rocket, planned_distance, sleep_interval=1, explosion_distance=0)
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
        total_elapsed = (current_time - start_time)
        interval_elapsed = current_time - previous_time
        previous_time = current_time

        rates = @rocket.calculate_rates_for(total_elapsed)
        @traveled_distance += (rates.speed * interval_elapsed) / @@KM_PER_HOUR_TO_SEC_RATIO
        @burnt_fuel += rates.burn_rate / @@L_PER_MI_TO_SEC_RATIO
        @total_time += interval_elapsed

        break if @traveled_distance >= @planned_distance
        yield(Stats.new(rates.speed, rates.burn_rate, @traveled_distance, @total_time, calculate_time_left(rates.speed))) if block_given?

        sleep(@sleep_interval)
      end

      @finished = true
    end

    def summary
      raise ArgumentError.new('No summary for incomplete flight') unless @finished

      Summary.new(@traveled_distance, @burnt_fuel, @total_time)
    end

    private
    def calculate_time_left(speed)
      (60 * (@planned_distance - @traveled_distance)).to_f / speed
    end

    def should_explode
      @explosion_distance > 0 and @traveled_distance >= @explosion_distance
    end
  end
end
