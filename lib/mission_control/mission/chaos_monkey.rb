module Mission
  class ChaosMonkey
    @@NO_ERROR = -1

    def initialize(random_generator, number_stages, flight_distance, auto_abort_rate, auto_explode_rate)
      @random = random_generator

      @valid_abort_options = number_stages
      @valid_explostion_distance = flight_distance
      @auto_abort_rate = auto_abort_rate
      @auto_explode_rate = auto_explode_rate

      @current_auto_abort_number = 0
      @current_auto_explode_number = 0

      @next_auto_abort = generate_next_occurence(@current_auto_explode_number, -1, auto_abort_rate, auto_abort_rate)
      @next_auto_explode = generate_next_occurence(@current_auto_abort_number, @next_auto_abort, auto_explode_rate, auto_explode_rate)
    end

    def chaos_for_mission
      @current_auto_abort_number += 1
      @current_auto_explode_number += 1

      if should_abort?
        @next_auto_abort = generate_next_occurence(@current_auto_explode_number, @next_auto_explode, @auto_abort_rate, @current_auto_abort_number)
        @current_auto_abort_number = 0

        return @random.rand(1...@valid_abort_options), @@NO_ERROR
      elsif should_explode?
        
        @next_auto_explode = generate_next_occurence(@current_auto_abort_number, @next_auto_abort, @auto_explode_rate, @current_auto_explode_number)
        @current_auto_explode_number = 0

        return @@NO_ERROR, @random.rand(1...@valid_explostion_distance)
      end
      
      return @@NO_ERROR, @@NO_ERROR
    end

    private

    def generate_next_occurence(next_event, existing_occurence, max_val, base)
      loop do
        next_random = @random.rand(1..max_val) + (max_val - base)

        return next_random if next_event + next_random != existing_occurence
      end
    end

    def should_abort?
      @current_auto_abort_number == @next_auto_abort
    end

    def should_explode?
      @current_auto_explode_number == @next_auto_explode
    end
  end
end
