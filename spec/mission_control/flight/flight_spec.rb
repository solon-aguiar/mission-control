RSpec.describe Flight::Flight do
  let(:rocket) { double('rocket') }
  let(:desired_distance) { 3.0 }
  let(:speed) { 3_600 }
  let(:burn_rate) { 168_240 }
  let(:sleep_interval) { 0 }
  let(:rocket_rates) { [speed, burn_rate] }

  let(:first_block_received_stat) {
    Flight::Stats.new(speed, burn_rate, 1, 1000, 2000)
  }
  let(:second_block_received_stat) {
    Flight::Stats.new(speed, burn_rate, 2, 2000, 1000)
  }

  describe 'launch!' do
    context 'when a block is provided' do
      it 'calls the block at every iteration' do
        expect(Time).to receive(:now).and_return(0, 1, 2, 3)
        expect(rocket).to receive(:calculate_rates_for).exactly(3).times.and_return(rocket_rates)

        flight = described_class.new(rocket, desired_distance, sleep_interval)
        expect { |b| flight.launch!(&b) }.to yield_successive_args(first_block_received_stat, second_block_received_stat)
      end
    end

    context 'with any call' do
      context 'when an explosion target is set' do
        it 'raises an error if the target is beyond the completion plan' do
          expect {
            described_class.new(rocket, desired_distance, sleep_interval, desired_distance + 1)
          }.to raise_error(ArgumentError)
        end

        it 'explodes at the determined location' do
          expect(Time).to receive(:now).and_return(0, 1, 2)
          expect(rocket).to receive(:calculate_rates_for).exactly(desired_distance - 1).times.and_return(rocket_rates)
          flight = described_class.new(rocket, desired_distance, sleep_interval, desired_distance - 1)

          flight.launch!

          expect(flight.finished?).to be(true)
          expect(flight.exploded?).to be(true)
        end
      end

      context 'when no explosion target is set' do
        it 'completes in the target' do
          expect(Time).to receive(:now).and_return(0, 1, 2, 3)
          expect(rocket).to receive(:calculate_rates_for).exactly(desired_distance).times.and_return(rocket_rates)
          flight = described_class.new(rocket, desired_distance, sleep_interval)

          flight.launch!

          expect(flight.finished?).to be(true)
          expect(flight.exploded?).to be(false)
        end
      end
    end
  end

  describe 'summary' do
    context 'when the flight explodes' do
      it 'calculates the summary' do
        expect(Time).to receive(:now).and_return(0, 1, 2)
          expect(rocket).to receive(:calculate_rates_for).exactly(desired_distance - 1).times.and_return(rocket_rates)
          flight = described_class.new(rocket, desired_distance, sleep_interval, desired_distance - 1)

          flight.launch!

          expect(flight.summary.travelled_distance).to be(desired_distance - 1)
          expect(flight.summary.total_time).to be(2000.0)
          expect(flight.summary.fuel_burnt).to be(burn_rate.to_f/60 * 2)
      end
    end

    context 'when the flight completes' do
      it 'calculates the summary' do
        expect(Time).to receive(:now).and_return(0, 1, 2, 3)
        expect(rocket).to receive(:calculate_rates_for).exactly(desired_distance).times.and_return(rocket_rates)
        flight = described_class.new(rocket, desired_distance, sleep_interval)

        flight.launch!

        expect(flight.summary.travelled_distance).to be(desired_distance)
        expect(flight.summary.total_time).to be(3000.0)
        expect(flight.summary.fuel_burnt).to be(burn_rate.to_f/60 * 3)
      end
    end
  end
end