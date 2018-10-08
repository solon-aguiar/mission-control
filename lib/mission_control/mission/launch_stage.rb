module Mission
  class LaunchStage
    attr_reader :stage_name, :is_final, :transitions

    def initialize(stage_name, transitions, is_final = false)
      @stage_name = stage_name
      @transitions = transitions
      @is_final = is_final
    end
  end
end
