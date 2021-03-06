RSpec.describe Mission::Mission do
  let(:rocket) { double('rocket') }
  let(:chaos_monkey) { double('chaos_monkey') }
  let(:name) { 'Apollo 13' }
  let(:planned_distance) { 3 }
  let(:speed) { 3_600 }
  let(:burn_rate) { 168_240 }
  let(:sleep_interval) { 0 }
  let(:rocket_rates) { [speed, burn_rate] }
  let(:no_auto_error) { [-1, -1] }
  let(:one_stage_plan) do
    second_to_last = Mission::LaunchStage.new(:second_to_last, {
      'abort': :aborted,
      'proceed': :completed
    })

    aborted = Mission::LaunchStage.new(:aborted, {}, true)
    completed = Mission::LaunchStage.new(:completed, {}, true)

    Mission::LaunchPlan.new(second_to_last, [aborted, completed])
  end
  let(:completed_stage_plan) do
    completed = Mission::LaunchStage.new(:completed, {}, true)

    Mission::LaunchPlan.new(completed, [])
  end
  let(:mission) { described_class.new(name, planned_distance, rocket, chaos_monkey) }


  describe 'start_launch_plan!' do
    it 'creates a launch plan' do
      expect(chaos_monkey).to receive(:chaos_for_mission).once.and_return(no_auto_error)

      mission.start_launch_plan!

      expect(mission.launch_plan_transitions).to eq([:abort, :proceed])
      expect(mission.launch_plan_state).to eq(:afterburner)
      expect(mission.ready_to_launch?).to be(false)
      expect(mission.launch_plan_aborted?).to be(false)
    end

    it 'adds the plan to the list of plans for the mission' do
      expect(chaos_monkey).to receive(:chaos_for_mission).twice.and_return(no_auto_error)

      mission.start_launch_plan!
      mission.start_launch_plan!

      expect(mission.summary.all_plans.size).to eq(2)
      expect(mission.summary.all_plans.first.aborted?).to eq(true)
      expect(mission.summary.all_plans.first.successful?).to eq(false)

      expect(mission.launch_plan_state).to eq(:afterburner)
      expect(mission.ready_to_launch?).to be(false)
      expect(mission.launch_plan_aborted?).to be(false)
    end
  end

  describe 'transition_launch_plan_to!' do
    context 'when there is a planned failure' do
      it 'fails on the first stage' do
        expect(chaos_monkey).to receive(:chaos_for_mission).once.and_return([1, -1])

        mission.start_launch_plan!
        mission.transition_launch_plan_to!(:proceed)

        expect(mission.launch_plan_transitions).to eq([])
        expect(mission.launch_plan_state).to eq('')
        expect(mission.ready_to_launch?).to be(false)
        expect(mission.launch_plan_aborted?).to be(true)
      end

      it 'fails on a mid stage' do
        expect(chaos_monkey).to receive(:chaos_for_mission).once.and_return([2, -1])

        mission.start_launch_plan!
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)

        expect(mission.launch_plan_transitions).to eq([])
        expect(mission.launch_plan_state).to eq('')
        expect(mission.ready_to_launch?).to be(false)
        expect(mission.launch_plan_aborted?).to be(true)
      end

      it 'fails on the last stage' do
        expect(chaos_monkey).to receive(:chaos_for_mission).once.and_return([4, -1])

        mission.start_launch_plan!
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)

        expect(mission.launch_plan_transitions).to eq([])
        expect(mission.launch_plan_state).to eq('')
        expect(mission.ready_to_launch?).to be(false)
        expect(mission.launch_plan_aborted?).to be(true)
      end
    end

    context 'when there is no planned failure' do
      it 'transitions to the next state' do
        expect(chaos_monkey).to receive(:chaos_for_mission).once.and_return(no_auto_error)

        mission.start_launch_plan!
        mission.transition_launch_plan_to!(:proceed)

        expect(mission.launch_plan_transitions).to eq([:abort, :proceed])
        expect(mission.launch_plan_state).to be(:disengaging)
        expect(mission.ready_to_launch?).to be(false)
        expect(mission.launch_plan_aborted?).to be(false)
      end

      it 'finishes the launch plan' do
        allow(LaunchPlanFactory).to receive(:build_launch_plan).once.and_return(one_stage_plan)
        expect(chaos_monkey).to receive(:chaos_for_mission).once.and_return(no_auto_error)

        mission.start_launch_plan!
        mission.transition_launch_plan_to!(:proceed)

        expect(mission.launch_plan_transitions).to eq([])
        expect(mission.launch_plan_state).to eq('')
        expect(mission.ready_to_launch?).to be(true)
        expect(mission.launch_plan_aborted?).to be(false)
      end
    end
  end

  describe 'launch_rocket!' do
    context 'when not ready' do
      it 'does not do anything' do
        expect(chaos_monkey).to receive(:chaos_for_mission).once.and_return(no_auto_error)

        mission.start_launch_plan!
        mission.launch_rocket!(sleep_interval)

        expect(mission.launch_plan_transitions).to eq([:abort, :proceed])
        expect(mission.launch_plan_state).to eq(:afterburner)
        expect(mission.ready_to_launch?).to be(false)
        expect(mission.launch_plan_aborted?).to be(false)
      end
    end

    context 'when there is a planned explosion' do
      it 'fails the flight' do
        allow(LaunchPlanFactory).to receive(:build_launch_plan).once.and_return(completed_stage_plan)

        expect(Time).to receive(:now).and_return(0, 1, 2)
        expect(rocket).to receive(:calculate_rates_for).exactly(planned_distance - 1).times.and_return(rocket_rates)
        expect(chaos_monkey).to receive(:chaos_for_mission).once.and_return([-1, 2])

        mission.start_launch_plan!
        mission.launch_rocket!(sleep_interval)

        expect(mission.flight_successful?).to be(false)
        expect(mission.summary.flight.nil?).to be(false)
      end
    end

    context 'when there is no planned explosion' do
      it 'completes the flight' do
        allow(LaunchPlanFactory).to receive(:build_launch_plan).once.and_return(completed_stage_plan)

        expect(Time).to receive(:now).and_return(0, 1, 2, 3)
        expect(rocket).to receive(:calculate_rates_for).exactly(planned_distance).times.and_return(rocket_rates)
        expect(chaos_monkey).to receive(:chaos_for_mission).once.and_return(no_auto_error)

        mission.start_launch_plan!
        mission.launch_rocket!(sleep_interval)

        expect(mission.flight_successful?).to be(true)
        expect(mission.summary.flight.nil?).to be(false)
      end
    end
  end
end