RSpec.describe Rocket::Engine do
  let(:avg_speed) { 1500 }
  let(:random) { double('random') }

  describe 'speed_at' do
    context 'when below estabilization speed' do
      it 'returns speed quadratic based' do
        engine = described_class.new(avg_speed, random)

        expect(engine.speed_at(0)).to eq(0)
        expect(engine.speed_at(1)).to eq(100)
        expect(engine.speed_at(2)).to eq(400)
        expect(engine.speed_at(3)).to eq(900)
        expect(random).to receive(:rand).exactly(0).times
      end
    end

    context 'when above estabilization speed' do
      it 'returns gaussian random value around average' do
        expect(random).to receive(:rand).exactly(4).times.and_return(0, 0, 0.1, 0.1)

        engine = described_class.new(avg_speed, random)
        expect(engine.speed_at(4)).to eq(1500)
        expect(engine.speed_at(5)).to eq(1500)
        expect(engine.speed_at(6)).to eq(1555.7061116438274)
        expect(engine.speed_at(7)).to eq(1540.4728591790551)
      end
    end
  end
  
end