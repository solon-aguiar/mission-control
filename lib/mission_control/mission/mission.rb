require_relative './launch_plan_factory'
require_relative './summary'

module Mission
  class Mission
    include LaunchPlanFactory

    def initialize(name, rocket)
      @name = name
      @rocket = rocket

      @all_launch_plans = []
      @ready_to_launch = false
      @launch_plan_aborted = false
    end

    def start_launch_plan!(chaos_monkey_result)
      return if @ready_to_launch
      
      unless @current_launch_plan.nil?
        transition_launch_plan_to!(:abort)
      end

      @launch_plan_aborted = false
      @chaos_monkey_result = chaos_monkey_result
      @current_launch_plan = build_launch_plan
      @current_stage_number = 1

      @all_launch_plans << @current_launch_plan
    end

    def ready_to_launch?
      @ready_to_launch
    end

    def launch_plan_aborted?
      @launch_plan_aborted
    end

    def launch_plan_state
      @current_launch_plan.current_stage_name unless @current_launch_plan.nil?
    end

    def launch_plan_transitions
      @current_launch_plan.nil? ? [] : @current_launch_plan.available_transitions
    end

    def transition_launch_plan_to!(label)
      return if @current_launch_plan.nil?

      if should_auto_abort?
        @current_launch_plan.transition_to!(:abort)
      else
        @current_launch_plan.transition_to!(label)
      end

      @launch_plan_aborted = @current_launch_plan.aborted?
      @ready_to_launch = @current_launch_plan.successful?
      @current_stage_number += 1

      if @current_launch_plan.completed?
        @current_launch_plan = nil
      end
    end

    def launch_rocket!(planned_distance, sleep_interval, &callback)
      return unless ready_to_launch?

      @flight = Flight::Flight.new(@rocket, planned_distance, sleep_interval, @chaos_monkey_result.explode_at)
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
      @chaos_monkey_result.abort_at != -1 and @current_stage_number == @chaos_monkey_result.abort_at
    end
  end
end