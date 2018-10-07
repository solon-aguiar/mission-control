require_relative './rocket/rocket_factory'
require_relative './mission/mission'
require_relative './config'
require_relative './mission/chaos_monkey'

module MissionControl
  class ControlPanel
    attr_reader :all_missions

    def initialize
      @chaos_monkey = Mission::ChaosMonkey.new(
        Random.new,
        Config::MISSION_STAGES,
        Config::MISSION_DISTANCE,
        Config::AUTO_ABORT_RATE,
        Config::AUTO_EXPLODE_RATE
      )
      @all_missions = []
    end

    def create_mission(name, seed)
      rocket = RocketFactory.build_rocket(seed)
      mission = Mission::Mission.new(name, Config::MISSION_DISTANCE, rocket, @chaos_monkey)
      all_missions << mission

      mission
    end

    def all_summaries
      all_missions.map {|m| m.summary }
    end
  end
end