RSpec.describe ChaosMonkey do
  context 'chaos_for_mission' do
    deterministic_limit = 7
    no_of_stages = 5
    mission_distance = 160
    auto_abort_rate = 3
    auto_explode_rate = 5

    it 'generates abort_at at "auto_abort_rate"' do
      monkey = described_class.new(DummyRandom.new(deterministic_limit), no_of_stages, mission_distance, auto_abort_rate, auto_explode_rate)      

      aborted_results = []
      (auto_abort_rate * 2).times do
        chaos_result = monkey.chaos_for_mission
        aborted_results << chaos_result if chaos_result.abort_at != -1
      end

      expect(aborted_results.size).to eq(2)
    end

    it 'generates explode_at at "auto_explode_rate"' do
      monkey = described_class.new(DummyRandom.new(deterministic_limit), no_of_stages, mission_distance, auto_abort_rate, auto_explode_rate)

      exploded_results = []
      (auto_explode_rate * 2).times do |i|
        chaos_result = monkey.chaos_for_mission
        exploded_results << chaos_result if chaos_result.explode_at != -1
      end

      expect(exploded_results.size).to eq(2)
    end

    it 'allows either explode_at or abort_at in the same mission' do
      monkey = described_class.new(DummyRandom.new(deterministic_limit), no_of_stages, mission_distance, auto_abort_rate, auto_explode_rate)

      aborted_results = []
      exploded_results = []
      (auto_abort_rate * auto_explode_rate).times do |i| #this generates a multiple which we want to avoid
        chaos_result = monkey.chaos_for_mission

        if chaos_result.explode_at != -1
          expect(chaos_result.abort_at).to be(-1)
        elsif chaos_result.abort_at != -1
          expect(chaos_result.explode_at).to be(-1)
        end

        exploded_results << chaos_result if chaos_result.explode_at != -1
        aborted_results << chaos_result if chaos_result.abort_at != -1
      end

      expect(exploded_results.size).to eq(auto_abort_rate)
      expect(aborted_results.size).to eq(auto_explode_rate + 1) # + 1 because we favor it in the conflict
    end
  end
end
