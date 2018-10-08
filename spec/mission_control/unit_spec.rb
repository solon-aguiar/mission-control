RSpec.describe Unit do

  describe 'ms_to_se' do
    it 'converts properly' do
      expect(Unit.ms_to_se(0)).to eq(0.0)
      expect(Unit.ms_to_se(1)).to eq(0.001)
      expect(Unit.ms_to_se(15)).to eq(0.015)
      expect(Unit.ms_to_se(1000)).to eq(1.0)
      expect(Unit.ms_to_se(30000)).to eq(30.0)
      expect(Unit.ms_to_se(300000)).to eq(300.0)
    end
  end

  describe 'se_to_ms' do
    it 'converts properly' do
      expect(Unit.se_to_ms(0)).to eq(0.0)
      expect(Unit.se_to_ms(0.5)).to eq(500.0)
      expect(Unit.se_to_ms(1)).to eq(1000.0)
      expect(Unit.se_to_ms(15)).to eq(15_000.0)
      expect(Unit.se_to_ms(1_000)).to eq(1000_000.0)
    end
  end

  describe 'km_per_hour_to_km_per_se' do
    it 'converts within an error range' do
      expect(Unit.km_per_hour_to_km_per_se(0)).to eq(0.0)
      expect(Unit.km_per_hour_to_km_per_se(0.5)).to be_within(0.0001).of(0.000138)
      expect(Unit.km_per_hour_to_km_per_se(1)).to be_within(0.0001).of(0.0002777)
      expect(Unit.km_per_hour_to_km_per_se(100)).to be_within(0.0001).of(0.02777)
      expect(Unit.km_per_hour_to_km_per_se(400)).to be_within(0.0001).of(0.11111)
      expect(Unit.km_per_hour_to_km_per_se(1_000)).to be_within(0.0001).of(0.27777)
      expect(Unit.km_per_hour_to_km_per_se(1_500)).to be_within(0.0001).of(0.41666)
      expect(Unit.km_per_hour_to_km_per_se(15_000)).to be_within(0.0001).of(4.1666)
    end
  end

  describe 'liters_per_minute_to_liters_per_sec' do
    it 'converts within an error range' do
      expect(Unit.liters_per_minute_to_liters_per_sec(0)).to eq(0.0)
      expect(Unit.liters_per_minute_to_liters_per_sec(0.5)).to be_within(0.0001).of(0.0083)
      expect(Unit.liters_per_minute_to_liters_per_sec(1)).to be_within(0.0001).of(0.01666)
      expect(Unit.liters_per_minute_to_liters_per_sec(100)).to be_within(0.0001).of(1.6666)
      expect(Unit.liters_per_minute_to_liters_per_sec(400)).to be_within(0.0001).of(6.6667)
      expect(Unit.liters_per_minute_to_liters_per_sec(1_000)).to be_within(0.0001).of(16.66666)
      expect(Unit.liters_per_minute_to_liters_per_sec(1_500)).to be_within(0.0001).of(25.0)
      expect(Unit.liters_per_minute_to_liters_per_sec(15_000)).to be_within(0.0001).of(250.0)
    end
  end
end