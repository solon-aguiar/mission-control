module Rocket
  class SimulatedParams
    attr_reader :speed, :burn_rate

    def initialize(speed, burn_rate)
      @speed = speed
      @burn_rate = burn_rate
    end
  end
end