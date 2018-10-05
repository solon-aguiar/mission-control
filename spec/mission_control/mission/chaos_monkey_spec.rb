RSpec.describe Mission::ChaosMonkey do
  let(:no_of_stages) { 4 }
  let(:mission_distance) { 160 }
  let(:auto_abort_rate) { 3 }
  let(:auto_explode_rate) { 5 }
  let(:random) { double('random') }

  describe 'chaos_for_mission' do
    deterministic_limit = 7

    it 'generates abort_at at "auto_abort_rate"' do
      expect(random).to receive(:rand).exactly(3).times.with(1..auto_abort_rate).and_return(auto_abort_rate)
      expect(random).to receive(:rand).exactly(2).times.with(1...no_of_stages).and_return(auto_abort_rate)

      #return 100 to avoid conflict
      expect(random).to receive(:rand).exactly(1).times.with(1..auto_explode_rate).and_return(100)

      monkey = described_class.new(random, no_of_stages, mission_distance, auto_abort_rate, auto_explode_rate)
      for i in (0..auto_abort_rate * 2) do
        abort_at, explode_at = monkey.chaos_for_mission
        if (i + 1) % auto_abort_rate == 0
          expect(abort_at).to eq(auto_abort_rate)
        else
          expect(abort_at).to eq(-1)
        end
      end
    end

    it 'generates explode_at at "auto_explode_rate"' do
      expect(random).to receive(:rand).exactly(3).times.with(1..auto_explode_rate).and_return(auto_explode_rate)
      expect(random).to receive(:rand).exactly(2).times.with(1...mission_distance).and_return(auto_explode_rate)

      #return 100 to avoid conflict
      expect(random).to receive(:rand).exactly(1).times.with(1..auto_abort_rate).and_return(100)
      
      monkey = described_class.new(random, no_of_stages, mission_distance, auto_abort_rate, auto_explode_rate)
      for i in (0..auto_explode_rate * 2) do
        abort_at, explode_at = monkey.chaos_for_mission
        if (i + 1) % auto_explode_rate == 0
          expect(explode_at).to eq(auto_explode_rate)
        else
          expect(explode_at).to eq(-1)
        end
      end
    end

    it 'allows either explode_at or abort_at in the same mission' do
      #creating a situation where on mission 15 the chaos monkey avoids having both abort_at and explode_ats
      expect(random).to receive(:rand).exactly(6).times.with(1..auto_abort_rate).and_return(auto_abort_rate, auto_abort_rate, auto_abort_rate, auto_abort_rate, auto_abort_rate, auto_abort_rate + 1)
      expect(random).to receive(:rand).exactly(4).times.with(1...no_of_stages).and_return(auto_abort_rate)

      expect(random).to receive(:rand).exactly(4).times.with(1..auto_explode_rate).and_return(auto_explode_rate)
      expect(random).to receive(:rand).exactly(3).times.with(1...mission_distance).and_return(auto_explode_rate)

      monkey = described_class.new(random, no_of_stages, mission_distance, auto_abort_rate, auto_explode_rate)
      for i in (0...auto_explode_rate * auto_abort_rate) do
        abort_at, explode_at = monkey.chaos_for_mission

        if (i + 1) % auto_explode_rate == 0
          expect(explode_at).to eq(auto_explode_rate)
          expect(abort_at).to eq(-1)
        elsif (i + 1) % auto_abort_rate == 0
          expect(explode_at).to eq(-1)
          expect(abort_at).to eq(auto_abort_rate)
        end
      end
    end
  end
end
