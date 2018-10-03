# Another useless doc
class ChaosMonkey
  def initialize(random_generator, number_stages, flight_distance, auto_abort_rate, auto_explode_rate)
    @random = random_generator

    @valid_abort_options = number_stages
    @valid_explostion_distance = flight_distance
    @auto_abort_rate = auto_abort_rate
    @auto_explode_rate = auto_explode_rate

    @current_auto_abort_number = 0
    @current_auto_explode_number = 0

    @next_auto_abort = generate_next_occurence(@current_auto_explode_number, -1, auto_abort_rate)
    @next_auto_explode = generate_next_occurence(@current_auto_abort_number, @next_auto_abort, auto_explode_rate)
  end

  def chaos_for_mission
    @current_auto_abort_number += 1
    @current_auto_explode_number += 1

    if should_abort?
      @current_auto_abort_number = 0
      @next_auto_abort = generate_next_occurence(@current_auto_explode_number, @next_auto_explode, @auto_abort_rate)

      return ChaosResult.new(@random.rand(@valid_abort_options))
    elsif should_explode?
      @current_auto_explode_number = 0
      @next_auto_explode = generate_next_occurence(@current_auto_abort_number, @next_auto_abort, @auto_explode_rate)

      return ChaosResult.new(-1, @random.rand(@valid_explostion_distance))
    end
    
    return ChaosResult.new
  end

  private
  def generate_next_occurence(base, existing_occurence, max_val)
    loop do
      next_random = @random.rand(max_val)

      return next_random if base + next_random != existing_occurence
    end
  end

  def should_abort?
    @current_auto_abort_number == @next_auto_abort
  end

  def should_explode?
    @current_auto_explode_number == @next_auto_explode
  end
end

class ChaosResult
  attr_reader :abort_at, :explode_at

  def initialize(abort_at = -1, explode_at = -1)
    @abort_at = abort_at
    @explode_at = explode_at
  end

  def to_s
    "abort_at = #{@abort_at}. explode_at = #{explode_at}"
  end
end
