module Mission
  class ChaosResult
    attr_reader :abort_at, :explode_at

    def initialize(abort_at = -1, explode_at = -1)
      @abort_at = abort_at
      @explode_at = explode_at
    end
  end
end