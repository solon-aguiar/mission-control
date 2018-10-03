RSpec.describe Mission::LaunchPlan do
  describe 'transition_to!' do
    context 'when already completed' do
      it 'raises ArgumentError' do
        stage = Mission::LaunchStage.new(:afterburner, {}, true)

        launch_plan = described_class.new(stage)

        expect {
          launch_plan.transition_to! :abc
        }.to raise_error(ArgumentError)
      end
    end

    context 'when not completed' do
      initial_stage = Mission::LaunchStage.new(:afterburner, {'proceed': :other_stage, 'abort': :aborted})
      other_stage = Mission::LaunchStage.new(:other_stage, {}, true)
      abort_stage = Mission::LaunchStage.new(:aborted, {}, true)

      it 'raises ArgumentError for no transition with the specified label' do
        launch_plan = described_class.new(initial_stage, [other_stage])

        expect {
          launch_plan.transition_to! :def
        }.to raise_error(ArgumentError)
      end

      it 'raises ArgumentError for invalid state transition' do
        bogus_initial_stage = Mission::LaunchStage.new(:afterburner, {'proceed': :another_stage})

        launch_plan = described_class.new(bogus_initial_stage, [other_stage])
        expect {
          launch_plan.transition_to! :proceed
        }.to raise_error(ArgumentError)
      end

      it 'marks as completed for abort' do
        launch_plan = described_class.new(initial_stage, [other_stage, abort_stage])
        expect(launch_plan.current_stage_name).to eq(:afterburner)

        launch_plan.transition_to! :abort

        expect(launch_plan.complete?).to eq(true)
        expect(launch_plan.aborted?).to eq(true)
        expect(launch_plan.successful?).to eq(false)
        expect(launch_plan.current_stage_name).to eq(:aborted)
      end

      it 'marks as completed for final state' do
        launch_plan = described_class.new(initial_stage, [other_stage, abort_stage])
        expect(launch_plan.current_stage_name).to eq(:afterburner)

        launch_plan.transition_to! :proceed

        expect(launch_plan.complete?).to eq(true)
        expect(launch_plan.aborted?).to eq(false)
        expect(launch_plan.successful?).to eq(true)
        expect(launch_plan.current_stage_name).to eq(:other_stage)
      end
    end
  end
end