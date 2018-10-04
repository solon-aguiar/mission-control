RSpec.describe Mission::Mission do
  let(:name) { 'Apollo 13' }
  let(:rocket) { double('rocket') }
  let(:desired_distance) { 3 }
  let(:speed) { 3_600 }
  let(:burn_rate) { 168_240 }
  let(:sleep_interval) { 0 }
  let(:rocket_rates) { Rocket::SimulatedParams.new(speed, burn_rate) }

  describe 'start_launch_plan!' do
    it 'creates a launch plan' do
      mission = described_class.new(name, rocket)
      expect(mission.launch_plan_transitions).to eq([])

      mission.start_launch_plan! (Mission::ChaosResult.new)

      expect(mission.launch_plan_transitions).to eq([:abort, :proceed])
      expect(mission.launch_plan_state).to eq(:afterburner)
      expect(mission.ready_to_launch?).to be(false)
      expect(mission.launch_plan_aborted?).to be(false)
    end

    it 'adds the plan to the list of plans for the mission' do
      mission = described_class.new(name, rocket)

      mission.start_launch_plan! (Mission::ChaosResult.new)
      mission.start_launch_plan! (Mission::ChaosResult.new)

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
        mission = described_class.new(name, rocket)

        mission.start_launch_plan! (Mission::ChaosResult.new(1))
        mission.transition_launch_plan_to!(:proceed)

        expect(mission.launch_plan_transitions).to eq([])
        expect(mission.launch_plan_state).to be(nil)
        expect(mission.ready_to_launch?).to be(false)
        expect(mission.launch_plan_aborted?).to be(true)
      end

      it 'fails on a mid stage' do
        mission = described_class.new(name, rocket)

        mission.start_launch_plan! (Mission::ChaosResult.new(2))
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)

        expect(mission.launch_plan_transitions).to eq([])
        expect(mission.launch_plan_state).to be(nil)
        expect(mission.ready_to_launch?).to be(false)
        expect(mission.launch_plan_aborted?).to be(true)
      end

      it 'fails on the last stage' do
        mission = described_class.new(name, rocket)

        mission.start_launch_plan! (Mission::ChaosResult.new(4))
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)

        expect(mission.launch_plan_transitions).to eq([])
        expect(mission.launch_plan_state).to be(nil)
        expect(mission.ready_to_launch?).to be(false)
        expect(mission.launch_plan_aborted?).to be(true)
      end
    end

    context 'when there is no planned failure' do
      it 'transitions to the next state' do
        mission = described_class.new(name, rocket)

        mission.start_launch_plan! Mission::ChaosResult.new
        mission.transition_launch_plan_to!(:proceed)

        expect(mission.launch_plan_transitions).to eq([:abort, :proceed])
        expect(mission.launch_plan_state).to be(:disengaging)
        expect(mission.ready_to_launch?).to be(false)
        expect(mission.launch_plan_aborted?).to be(false)
      end

      it 'finishes the launch plan' do
        mission = described_class.new(name, rocket)

        mission.start_launch_plan! Mission::ChaosResult.new
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)

        expect(mission.launch_plan_transitions).to eq([])
        expect(mission.launch_plan_state).to be(nil)
        expect(mission.ready_to_launch?).to be(true)
        expect(mission.launch_plan_aborted?).to be(false)
      end
    end
  end

  describe 'launch_rocket!' do
    context 'when not ready' do
      it 'does not do anything' do
        mission = described_class.new(name, rocket)
        mission.start_launch_plan! Mission::ChaosResult.new

        mission.launch_rocket!(desired_distance, sleep_interval)

        expect(mission.launch_plan_transitions).to eq([:abort, :proceed])
        expect(mission.launch_plan_state).to eq(:afterburner)
        expect(mission.ready_to_launch?).to be(false)
        expect(mission.launch_plan_aborted?).to be(false)
      end
    end

    context 'when there is a planned explosion' do
      it 'fails the flight' do
        expect(Time).to receive(:now).and_return(0, 1, 2)
        expect(rocket).to receive(:calculate_rates_for).exactly(desired_distance - 1).times.and_return(rocket_rates)

        mission = described_class.new(name, rocket)
        mission.start_launch_plan! Mission::ChaosResult.new(-1, 2)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)

        mission.launch_rocket!(desired_distance, sleep_interval)

        expect(mission.flight_successful?).to be(false)
        expect(mission.summary.flight.nil?).to be(false)
      end
    end

    context 'when there is no planned explosion' do
      it 'completes the flight' do
        expect(Time).to receive(:now).and_return(0, 1, 2, 3)
        expect(rocket).to receive(:calculate_rates_for).exactly(desired_distance).times.and_return(rocket_rates)

        mission = described_class.new(name, rocket)
        mission.start_launch_plan! Mission::ChaosResult.new
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)
        mission.transition_launch_plan_to!(:proceed)

        mission.launch_rocket!(desired_distance, sleep_interval)

        expect(mission.flight_successful?).to be(true)
        expect(mission.summary.flight.nil?).to be(false)
      end
    end
  end
end