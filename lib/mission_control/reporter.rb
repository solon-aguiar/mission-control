require_relative './config'

class Reporter
  def initialize(localization)
    @localization = localization
  end

  def build_mission_plan(seed_val)
    title = @localization.get_localized_string(:mission_plan)

    travel_distance_val = @localization.format_float(Config::MISSION_DISTANCE, 1)
    travel_distance = @localization.get_localized_string(
      :travel_distance,
      travel_distance_val.rjust(6, ' ')
    )

    capacity_val = @localization.format_integer(Config::PAYLOAD_CAPACITY)
    capacity = @localization.get_localized_string(
      :payload_capacity,
      capacity_val.rjust(1, ' ')
    )

    fuel_val = @localization.format_integer(Config::FUEL_CAPACITY)
    fuel_capacity = @localization.get_localized_string(
      :fuel_capacity,
      fuel_val.rjust(12, ' ')
    )

    burn_val = @localization.format_integer(Config::ROCKET_AVERAGE_BURN_RATE)
    burn_rate = @localization.get_localized_string(
      :burn_rate,
      burn_val.rjust(14, ' ')
    )

    speed_val = @localization.format_integer(Config::ENGINE_AVERAGE_SPEED)
    average_speed = @localization.get_localized_string(
      :average_speed,
      speed_val.rjust(8, ' ')
    )

    seed_str = @localization.format_integer(seed_val)
    seed = @localization.get_localized_string(
      :random_seed,
      seed_str.rjust(7, ' ')
    )

    create_multiline(title, travel_distance, capacity, fuel_capacity, burn_rate, average_speed, seed)
  end

  def build_missions_summary(all_summaries)
    title = @localization.get_localized_string(:mission_summary)
    total_distance_val = @localization.format_float(calculate_total(all_summaries, :travelled_distance), 2)
    total_distance = @localization.get_localized_string(
      :total_distance,
      total_distance_val
    )

    retries_abort_val = "#{calculate_aborts(all_summaries)}/#{calculate_retries(all_summaries)}"
    retries_abort_no = @localization.get_localized_string(
      :retries_abort_no,
      retries_abort_val
    )

    explosions_val = @localization.format_integer(calculate_total_explosions(all_summaries))
    no_explosions = @localization.get_localized_string(
      :no_explosions,
      explosions_val
    )

    total_fuel_val = @localization.format_integer(calculate_total(all_summaries, :fuel_burnt))
    total_fuel_burnt = @localization.get_localized_string(
      :total_fuel_burnt,
      total_fuel_val
    )

    total_time_val = @localization.format_time(calculate_total(all_summaries, :total_time))
    flight_time = @localization.get_localized_string(
      :flight_time,
      total_time_val
    )

    create_multiline(title, total_distance, retries_abort_no, no_explosions, total_fuel_burnt, flight_time)
  end

  def build_mission_status(flight_status)
    title = @localization.get_localized_string(:mission_status)

    burn_val = @localization.format_integer(flight_status.burn_rate)
    fuel_burn_rate = @localization.get_localized_string(
      :fuel_burn_rate,
      burn_val
    )

    speed_val = @localization.format_integer(flight_status.speed)
    current_speed = @localization.get_localized_string(
      :current_speed,
      speed_val
    )

    travel_distance_val = @localization.format_float(flight_status.traveled_distance, 1)
    current_distance = @localization.get_localized_string(
      :current_distance,
      travel_distance_val
    )

    elapsed_time_val = @localization.format_time(flight_status.elapsed_time)
    elapsed_time = @localization.get_localized_string(
      :elapsed_time,
      elapsed_time_val
    )

    time_left_val = @localization.format_time(flight_status.time_to_go)
    time_left = @localization.get_localized_string(
      :time_left,
      time_left_val
    )

    create_multiline(title, fuel_burn_rate, current_speed, current_distance, elapsed_time, time_left)
  end

  private
  def create_multiline(*args)
    tail = args[1..-1].map {|e| "  #{e}\n"}.join('')
    head = "#{args[0]}\n"

    "#{head}#{tail}"
  end

  def calculate_retries(all_summaries)
    all_summaries.inject(0) do |sum, next_summary|
      sum + next_summary.all_plans.size - 1
    end
  end

  def calculate_aborts(all_summaries)
    all_summaries.inject(0) do |sum, next_summary|
      sum + next_summary.all_plans.count do |plan|
        plan.aborted?
      end
    end
  end

  def calculate_total(all_summaries, field)
    all_summaries.inject(0) do |sum, next_summary|
      sum + (next_summary.flight.nil? ? 0 : next_summary.flight.summary.send(field))
    end
  end

  def calculate_total_explosions(all_summaries)
     all_summaries.inject(0) do |sum, next_summary|
      sum + (next_summary.flight.nil? ? 0 : next_summary.flight.exploded? ? 1 : 0)
    end
  end
end