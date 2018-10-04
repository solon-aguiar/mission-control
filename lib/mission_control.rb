require_relative 'mission_control/flight/flight'

require_relative 'mission_control/mission/chaos_monkey'
require_relative 'mission_control/mission/launch_plan'
require_relative 'mission_control/mission/launch_stage'
require_relative 'mission_control/mission/mission'

require_relative 'mission_control/rocket/rocket'
require_relative 'mission_control/rocket/simulated_params'

# Basic class
class MissionControl
  def play
    'game on!'
  end
end
