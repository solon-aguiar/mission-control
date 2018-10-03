RSpec.describe Rocket::Rocket do
  burn_rate = 168240
  avg_speed = 1500

  context 'when below estabilization time' do
    it 'calculates based on quadratic speed' do
      rocket = described_class.new(burn_rate, avg_speed, DummyRandom.new(0, avg_speed))

      rates = rocket.calculate_rates_for(0)
      expect(rates.speed).to eq(0)
      expect(rates.burn_rate).to eq(0)

      rates = rocket.calculate_rates_for(1)
      expect(rates.speed).to eq(100)
      expect(rates.burn_rate).to eq(11216)

      rates = rocket.calculate_rates_for(2)
      expect(rates.speed).to eq(400)
      expect(rates.burn_rate).to eq(44864)

      rates = rocket.calculate_rates_for(3)
      expect(rates.speed).to eq(900)
      expect(rates.burn_rate).to eq(100944)
    end
  end

  context 'when at the estabilization time' do
    it 'calculates based on random speed' do
      rocket = described_class.new(burn_rate, avg_speed, DummyRandom.new(1, avg_speed))

      rates = rocket.calculate_rates_for(4)
      expect(rates.speed).to eq(avg_speed)
      expect(rates.burn_rate).to eq(burn_rate)
    end
  end

  context 'when after the estabilization time' do
    it 'calculates based on random speed' do
      rocket = described_class.new(burn_rate, avg_speed, DummyRandom.new(0, avg_speed))

      rates = rocket.calculate_rates_for(5)
      expect(rates.speed).to eq(avg_speed - 1)
      expect(rates.burn_rate).to eq(168127.84)
    end
  end
end