module Mission
  def default_plan
    intial_stage = LaunchStage.new(:afterburner, {
      'abort': :aborted,
      'proceed': :disengaging
    })

    disengaging = LaunchStage.new(:disengaging, {
      'abort': :aborted,
      'proceed': :cross_checking
    })

    cross_checking = LaunchStage.new(:cross_checking, {
      'abort': :aborted,
      'proceed': :launching
    })

    launching = LaunchStage.new(:launching, {
      'abort': :aborted,
      'proceed': :completed
    })

    aborted = LaunchStage.new(:aborted, {}, true)
    completed = LaunchStage.new(:completed, {}, true)

    LaunchPlan.new(initial_stage, [initial_stage, disengaging, cross_checking, launching, aborted, completed])
  end
end