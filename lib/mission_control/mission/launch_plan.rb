module Mission
  class LaunchPlan
    def initialize(initial_stage, other_stages = [])
      @completed = initial_stage.is_final
      @current_stage = initial_stage

      @internal_stages = {}
      other_stages.each do |stage|
        @internal_stages[stage.stage_name] = stage
      end

      @internal_stages[@current_stage.stage_name] = @current_stage
    end

    def current_stage_name
      @current_stage.stage_name
    end

    def available_transitions
      @current_stage.transitions.keys
    end

    def completed?
      @completed
    end

    def aborted?
      @completed && @current_stage.stage_name == :aborted
    end

    def successful?
      @completed && !aborted?
    end

    def transition_to!(label)
      raise ArgumentError.new('Cannot transition a completed plan!') if completed?

      next_stage_name = @current_stage.transitions[label]
      raise ArgumentError.new('Invalid transition') if next_stage_name.nil? || @internal_stages[next_stage_name].nil?

      @current_stage = @internal_stages[next_stage_name]
      @completed = @current_stage.is_final || current_stage_name == :aborted
    end
  end
end
