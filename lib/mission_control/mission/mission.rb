require_relative './launch_plan_factory'
require_relative './summary'

module Mission
  class Mission
    include LaunchPlanFactory

    def initialize(name, planned_distance, rocket)
      @name = name
      @rocket = rocket
      @planned_distance = planned_distance
      @all_launch_plans = []
    end

    def start_launch_plan!(chaos_monkey_result)
      return if @ready_to_launch
      transition_launch_plan_to!(:abort) if has_valid_current_launch_plan?

      @abort_at, @explode_at = chaos_monkey_result
      @current_launch_plan = build_launch_plan
      @current_stage_number = 1

      @all_launch_plans << @current_launch_plan
    end

    def ready_to_launch?
      @current_launch_plan.successful?
    end

    def launch_plan_aborted?
      @current_launch_plan.aborted?
    end

    def launch_plan_state
      has_valid_current_launch_plan? ? @current_launch_plan.current_stage_name : '' 
    end

    def launch_plan_transitions
      has_valid_current_launch_plan? ? @current_launch_plan.available_transitions : []
    end

    def transition_launch_plan_to!(label)
      return if @current_launch_plan.nil? or @current_launch_plan.completed?

      if should_auto_abort?
        @current_launch_plan.transition_to!(:abort)
      else
        @current_launch_plan.transition_to!(label)
      end

      @current_stage_number += 1
    end

    def launch_rocket!(sleep_interval, &callback)
      return unless ready_to_launch?

      @flight = Flight::Flight.new(@rocket, @planned_distance, sleep_interval, @explode_at)
      @flight.launch!(&callback)
    end

    def summary
      Summary.new(@all_launch_plans, @flight)
    end

    def flight_successful?
      !@flight.exploded?
    end

    private
    def should_auto_abort?
      @current_stage_number == @abort_at
    end

    def has_valid_current_launch_plan?
      !@current_launch_plan.nil? && !@current_launch_plan.completed?
    end
  end
end