require_relative './launch_stage'
require_relative './launch_plan'

module LaunchPlanFactory
  def build_launch_plan
    initial_stage = Mission::LaunchStage.new(:afterburner, {
      'abort': :aborted,
      'proceed': :disengaging
    })

    disengaging = Mission::LaunchStage.new(:disengaging, {
      'abort': :aborted,
      'proceed': :cross_checking
    })

    cross_checking = Mission::LaunchStage.new(:cross_checking, {
      'abort': :aborted,
      'proceed': :launching
    })

    launching = Mission::LaunchStage.new(:launching, {
      'abort': :aborted,
      'proceed': :completed
    })

    aborted = Mission::LaunchStage.new(:aborted, {}, true)
    completed = Mission::LaunchStage.new(:completed, {}, true)

    Mission::LaunchPlan.new(initial_stage, [disengaging, cross_checking, launching, aborted, completed])
  end
end