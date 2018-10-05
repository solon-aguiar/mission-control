RSpec.describe Rocket::Rocket do
  let(:burn_rate) { 168240 }
  let(:avg_speed) { 1500 }
  let(:t1_speed) { 100 }
  let(:t5_speed) { 1499 }

  let(:engine) { double('engine') }

  describe 'calculate_rates_for(t)' do
    it 'calculates based burn rate based on engine speed' do
      expect(engine).to receive(:speed_at).exactly(2).times.and_return(100, 1499)     
      expect(engine).to receive(:avg_speed).exactly(2).times.and_return(avg_speed) 

      rocket = described_class.new(burn_rate, engine)

      speed, burn_rate = rocket.calculate_rates_for(1)
      expect(speed).to eq(t1_speed)
      expect(burn_rate).to eq(11216)

      speed, burn_rate = rocket.calculate_rates_for(5)
      expect(speed).to eq(t5_speed)
      expect(burn_rate).to eq(168127.84)
    end
  end
end