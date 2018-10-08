RSpec.describe Reporter do
  let(:localization) { Localization.new(:en_US) }
  let(:seed) { 12 }
  let(:thirty_seconds) { 30 * 1000 }
  let(:five_minutes_forty_seconds) { 5 * 60 * 1000 + 40 * 1000 }

  describe 'build_mission_plan' do
    it 'justifies the text correctly' do
      reporter = described_class.new(localization)

      plan_string = reporter.build_mission_plan(seed)
      expect(plan_string).to eq(
        %{Mission plan:
  Travel distance:  160.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    1,500 km/h
  Random seed:      12
}
      )
    end

    it 'justifies the smaller seeds correctly' do
      reporter = described_class.new(localization)

      plan_string = reporter.build_mission_plan(2)
      expect(plan_string).to eq(
        %{Mission plan:
  Travel distance:  160.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    1,500 km/h
  Random seed:      2
}
      )
    end
  end

  describe 'build_missions_summary' do
    let(:complete_launch_plan) { double('complete_launch_plan', :aborted? => false) }
    let(:incomplete_launch_plan) { double('complete_launch_plan', :aborted? => true) }
    let(:complete_flight_summary) { Flight::Summary.new(160, 10_000_000.01, five_minutes_forty_seconds) }
    let(:incomplete_flight_summary) { Flight::Summary.new(100, 3_500, thirty_seconds) }
    let(:complete_flight) { double('complete_flight', :exploded? => false, :summary => complete_flight_summary) }
    let(:incomplete_flight) { double('incomplete_flight', :exploded? => true, :summary => incomplete_flight_summary) }

    it 'accounts correctly for aborts and retries' do
      summary = Mission::Summary.new([incomplete_launch_plan, incomplete_launch_plan, complete_launch_plan], complete_flight)

      reporter = described_class.new(localization)
      summary_string = reporter.build_missions_summary([summary])
      expect(summary_string).to eq(
        %{All missions summary:
  Total distance traveled: 160.00 km
  Number of abort and retries: 2/2
  Number of explosions: 0
  Total fuel burned: 10,000,000 liters
  Flight time: 0:05:40
}
      )
    end

    it 'accounts correctly for explosions' do
      summary = Mission::Summary.new([incomplete_launch_plan, incomplete_launch_plan, complete_launch_plan], incomplete_flight)

      reporter = described_class.new(localization)
      summary_string = reporter.build_missions_summary([summary])
      expect(summary_string).to eq(
        %{All missions summary:
  Total distance traveled: 100.00 km
  Number of abort and retries: 2/2
  Number of explosions: 1
  Total fuel burned: 3,500 liters
  Flight time: 0:00:30
}
      )
    end

    it 'combines all missions data' do
      summary = Mission::Summary.new([incomplete_launch_plan, incomplete_launch_plan, complete_launch_plan], incomplete_flight)
      another_summary = Mission::Summary.new([complete_launch_plan], complete_flight)

      reporter = described_class.new(localization)
      summary_string = reporter.build_missions_summary([summary, another_summary])
      expect(summary_string).to eq(
        %{All missions summary:
  Total distance traveled: 260.00 km
  Number of abort and retries: 2/2
  Number of explosions: 1
  Total fuel burned: 10,003,500 liters
  Flight time: 0:06:10
}
      )
    end

    it 'ignores when the mission did not have a flight' do
      summary = Mission::Summary.new([incomplete_launch_plan, incomplete_launch_plan, complete_launch_plan], incomplete_flight)
      another_summary = Mission::Summary.new([complete_launch_plan], complete_flight)
      a_third_summary = Mission::Summary.new([incomplete_launch_plan], nil)

      reporter = described_class.new(localization)
      summary_string = reporter.build_missions_summary([summary, another_summary, a_third_summary])
      expect(summary_string).to eq(
        %{All missions summary:
  Total distance traveled: 260.00 km
  Number of abort and retries: 3/2
  Number of explosions: 1
  Total fuel burned: 10,003,500 liters
  Flight time: 0:06:10
}
      )
    end
  end

  describe 'build_mission_summary' do
    let(:complete_launch_plan) { double('complete_launch_plan', :aborted? => false) }
    let(:incomplete_launch_plan) { double('complete_launch_plan', :aborted? => true) }
    let(:complete_flight_summary) { Flight::Summary.new(160, 10_000_000.01, five_minutes_forty_seconds) }
    let(:incomplete_flight_summary) { Flight::Summary.new(100, 3_500, thirty_seconds) }
    let(:complete_flight) { double('complete_flight', :exploded? => false, :summary => complete_flight_summary) }
    let(:incomplete_flight) { double('incomplete_flight', :exploded? => true, :summary => incomplete_flight_summary) }

    it 'accounts correctly for aborts and retries' do
      summary = Mission::Summary.new([incomplete_launch_plan, incomplete_launch_plan, complete_launch_plan], complete_flight)

      reporter = described_class.new(localization)
      summary_string = reporter.build_mission_summary(summary)
      expect(summary_string).to eq(
        %{Mission summary:
  Total distance traveled: 160.00 km
  Number of abort and retries: 2/2
  Number of explosions: 0
  Total fuel burned: 10,000,000 liters
  Flight time: 0:05:40
}
      )
    end

    it 'accounts correctly for explosions' do
      summary = Mission::Summary.new([incomplete_launch_plan, incomplete_launch_plan, complete_launch_plan], incomplete_flight)

      reporter = described_class.new(localization)
      summary_string = reporter.build_mission_summary(summary)
      expect(summary_string).to eq(
        %{Mission summary:
  Total distance traveled: 100.00 km
  Number of abort and retries: 2/2
  Number of explosions: 1
  Total fuel burned: 3,500 liters
  Flight time: 0:00:30
}
      )
    end
  end

  describe 'build_mission_status' do
    it 'formats all the fields' do
      reporter = described_class.new(localization)
      flight_status = Flight::Stats.new(1_350.312, 151_416.187, 12.51, thirty_seconds, five_minutes_forty_seconds)

      status_string = reporter.build_mission_status(flight_status)
      expect(status_string).to eq(
        %{Mission status:
  Current fuel burn rate: 151,416 liters/min
  Current speed: 1,350 km/h
  Current distance traveled: 12.5 km
  Elapsed time: 0:00:30
  Time to destination: 0:05:40
}
      )
    end
  end
end