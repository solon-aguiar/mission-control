RSpec.describe Mission::Mission do
  let(:name) { 'Apollo 13' }
  let(:rocket) { double('rocket') }
  let(:planned_distance) { 3 }
  let(:speed) { 3_600 }
  let(:burn_rate) { 168_240 }
  let(:sleep_interval) { 0 }
  let(:rocket_rates) { [speed, burn_rate] }
  let(:mission) { described_class.new(name, planned_distance, rocket) }

  describe 'start_launch_plan!' do
    it 'creates a launch plan' do
      expect(mission.launch_plan_transitions).to eq([])

      mission.start_launch_plan! ([-1,-1])

      expect(mission.launch_plan_transitions).to eq([:abort, :proceed])
      expect(mission.launch_plan_state).to eq(:afterburner)
      expect(mission.ready_to_launch?).to be(false)
      expect(mission.launch_plan_aborted?).to be(false)
    end

    it 'adds the plan to the list of plans for the mission' do
      mission.start_launch_plan! ([-1,-1])
      mission.start_launch_plan! ([-1,-1])

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
        mission.start_launch_plan! ([1,-1])
        mission.transition_launch_plan_to!(:proceed)

        expect(mission.launch_plan_transitions).to eq([])
        expect(mission.launch_plan_state).to eq('')
        expect(mission.ready_to_launch?).to be(false)
        expect(mission.launch_plan_aborted?).to be(true)
      end

      it 'fails on a mid stage' do
        mission.start_launch_plan! ([2,-1])
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)

        expect(mission.launch_plan_transitions).to eq([])
        expect(mission.launch_plan_state).to eq('')
        expect(mission.ready_to_launch?).to be(false)
        expect(mission.launch_plan_aborted?).to be(true)
      end

      it 'fails on the last stage' do
        mission.start_launch_plan! ([4,-1])
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
        mission.start_launch_plan! ([-1,-1])
        mission.transition_launch_plan_to!(:proceed)

        expect(mission.launch_plan_transitions).to eq([:abort, :proceed])
        expect(mission.launch_plan_state).to be(:disengaging)
        expect(mission.ready_to_launch?).to be(false)
        expect(mission.launch_plan_aborted?).to be(false)
      end

      it 'finishes the launch plan' do
        mission.start_launch_plan! ([-1,-1])
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
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
        mission.start_launch_plan! ([-1,-1])

        mission.launch_rocket!(sleep_interval)

        expect(mission.launch_plan_transitions).to eq([:abort, :proceed])
        expect(mission.launch_plan_state).to eq(:afterburner)
        expect(mission.ready_to_launch?).to be(false)
        expect(mission.launch_plan_aborted?).to be(false)
      end
    end

    context 'when there is a planned explosion' do
      it 'fails the flight' do
        expect(Time).to receive(:now).and_return(0, 1, 2)
        expect(rocket).to receive(:calculate_rates_for).exactly(planned_distance - 1).times.and_return(rocket_rates)
        mission.start_launch_plan! ([-1,2])
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)

        mission.launch_rocket!(sleep_interval)

        expect(mission.flight_successful?).to be(false)
        expect(mission.summary.flight.nil?).to be(false)
      end
    end

    context 'when there is no planned explosion' do
      it 'completes the flight' do
        expect(Time).to receive(:now).and_return(0, 1, 2, 3)
        expect(rocket).to receive(:calculate_rates_for).exactly(planned_distance).times.and_return(rocket_rates)

        mission.start_launch_plan! ([-1,-1])
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)

        mission.launch_rocket!(sleep_interval)

        expect(mission.flight_successful?).to be(true)
        expect(mission.summary.flight.nil?).to be(false)
      end
    end
  end
end