describe MissionControl::Game do
  let(:mission_name) { 'Apollo 11' }
  let(:anoter_mission_name) { 'Apollo 13' }
  let(:invalid_mission_name) { ' ' }
  let(:yes_answer) { 'Y' }
  let(:no_answer) { 'n' }
  let(:invalid_answer) { 'N' }
  let(:mission_distance) { 4.0 }
  let(:speed) { 3_600 }
  let(:burn_rate) { 168_240 }
  let(:sleep_interval) { 0 }
  let(:report_interval) { 1 }
  let(:no_error) { -1 }
  let(:seed) { 34 }

  describe 'play' do
    before(:each) do
      stub_const("Config::MISSION_DISTANCE", mission_distance)
      stub_const("Config::ENGINE_AVERAGE_SPEED", speed)
      stub_const("Config::ROCKET_AVERAGE_BURN_RATE", burn_rate)
      stub_const("Config::SLEEP_INTERVAL", sleep_interval)
      stub_const("Config::REPORT_INTERVAL", report_interval)

      allow_any_instance_of(Rocket::Engine).to receive(:speed_at).and_return(speed)
      allow(Random).to receive(:rand).with(100).and_return(seed)
    end

    context 'when no auto-abort or explosion' do
      before(:each) do
        allow_any_instance_of(Mission::ChaosMonkey).to receive(:chaos_for_mission).and_return([no_error, no_error])
      end

      it 'shows all the prompts and tracking information' do
        expect(Time).to receive(:now).and_return(0, 1, 2, 3, 4)
        allow($stdin).to receive(:gets).and_return(
          mission_name,
          yes_answer, yes_answer, yes_answer, yes_answer, # mission plan stages
          no_answer # no more missions
        )

        game = MissionControl::Game.new
         expect {
           game.play
         }.to output(
          %{Welcome to Mission Control!
Mission plan:
  Travel distance:    4.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    3,600 km/h
  Random seed:      34
What is the name of this mission? Engage afterburner? (Y/n) Release support structures? (Y/n) Perform cross-checks? (Y/n) Launch? (Y/n) Launched! Please wait for updates...
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 2.0 km
  Elapsed time: 0:00:02
  Time to destination: 0:00:02
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 3.0 km
  Elapsed time: 0:00:03
  Time to destination: 0:00:01
Mission completed!
Mission summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 0/0
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Would you like to run another mission? (Y/n) All missions summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 0/0
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Bye bye! Hope you enjoyed it!
}
          ).to_stdout
      end

      it 'asks for valid mission name name' do
        expect(Time).to receive(:now).and_return(0, 1, 2, 3, 4)
        allow($stdin).to receive(:gets).and_return(
          invalid_mission_name, mission_name,
          yes_answer, yes_answer, yes_answer, yes_answer, # mission plan stages
          no_answer # no more missions
        )

        game = MissionControl::Game.new
         expect {
           game.play
         }.to output(
          %{Welcome to Mission Control!
Mission plan:
  Travel distance:    4.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    3,600 km/h
  Random seed:      34
What is the name of this mission? Please provide a non-empty mission name!
What is the name of this mission? Engage afterburner? (Y/n) Release support structures? (Y/n) Perform cross-checks? (Y/n) Launch? (Y/n) Launched! Please wait for updates...
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 2.0 km
  Elapsed time: 0:00:02
  Time to destination: 0:00:02
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 3.0 km
  Elapsed time: 0:00:03
  Time to destination: 0:00:01
Mission completed!
Mission summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 0/0
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Would you like to run another mission? (Y/n) All missions summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 0/0
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Bye bye! Hope you enjoyed it!
}
          ).to_stdout
      end

      it 'asks for valid choice' do
        expect(Time).to receive(:now).and_return(0, 1, 2, 3, 4)
        allow($stdin).to receive(:gets).and_return(
          mission_name,
          invalid_answer, yes_answer, yes_answer, yes_answer, yes_answer, # mission plan stages
          no_answer # no more missions
        )

        game = MissionControl::Game.new
         expect {
           game.play
         }.to output(
          %{Welcome to Mission Control!
Mission plan:
  Travel distance:    4.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    3,600 km/h
  Random seed:      34
What is the name of this mission? Engage afterburner? (Y/n) Please provide a valid value!
Engage afterburner? (Y/n) Release support structures? (Y/n) Perform cross-checks? (Y/n) Launch? (Y/n) Launched! Please wait for updates...
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 2.0 km
  Elapsed time: 0:00:02
  Time to destination: 0:00:02
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 3.0 km
  Elapsed time: 0:00:03
  Time to destination: 0:00:01
Mission completed!
Mission summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 0/0
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Would you like to run another mission? (Y/n) All missions summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 0/0
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Bye bye! Hope you enjoyed it!
}
          ).to_stdout
      end

      it 'allows for retry' do
        expect(Time).to receive(:now).and_return(0, 1, 2, 3, 4)
        allow($stdin).to receive(:gets).and_return(
          mission_name,
          no_answer, # first mission plan
          yes_answer, # retry
          yes_answer, yes_answer, yes_answer, yes_answer, #second mission plan
          no_answer # no more missions
        )

        game = MissionControl::Game.new
         expect {
           game.play
         }.to output(
          %{Welcome to Mission Control!
Mission plan:
  Travel distance:    4.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    3,600 km/h
  Random seed:      34
What is the name of this mission? Engage afterburner? (Y/n) Mission aborted!
Would you like to retry? (Y/n) Engage afterburner? (Y/n) Release support structures? (Y/n) Perform cross-checks? (Y/n) Launch? (Y/n) Launched! Please wait for updates...
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 2.0 km
  Elapsed time: 0:00:02
  Time to destination: 0:00:02
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 3.0 km
  Elapsed time: 0:00:03
  Time to destination: 0:00:01
Mission completed!
Mission summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 1/1
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Would you like to run another mission? (Y/n) All missions summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 1/1
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Bye bye! Hope you enjoyed it!
}
          ).to_stdout
      end

      it 'works when no retries are performed' do
        expect(Time).not_to receive(:now)
        allow($stdin).to receive(:gets).and_return(
          mission_name,
          no_answer, # first mission plan
          no_answer, # no retry
          no_answer # no more missions
        )

        game = MissionControl::Game.new
         expect {
           game.play
         }.to output(
          %{Welcome to Mission Control!
Mission plan:
  Travel distance:    4.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    3,600 km/h
  Random seed:      34
What is the name of this mission? Engage afterburner? (Y/n) Mission aborted!
Would you like to retry? (Y/n) Mission summary:
  Total distance traveled: 0.00 km
  Number of abort and retries: 1/0
  Number of explosions: 0
  Total fuel burned: 0 liters
  Flight time: 0:00:00
Would you like to run another mission? (Y/n) All missions summary:
  Total distance traveled: 0.00 km
  Number of abort and retries: 1/0
  Number of explosions: 0
  Total fuel burned: 0 liters
  Flight time: 0:00:00
Bye bye! Hope you enjoyed it!
}
          ).to_stdout
      end

      it 'allows many missions' do
        expect(Time).to receive(:now).and_return(0, 1, 2, 3, 4, 0, 1, 2, 3, 4)
        allow($stdin).to receive(:gets).and_return(
          mission_name,
          yes_answer, yes_answer, yes_answer, yes_answer, # mission plan stages
          yes_answer, # one more mission
          anoter_mission_name,
          yes_answer, yes_answer, yes_answer, yes_answer, # mission plan stages
          no_answer # no more missions
        )

        game = MissionControl::Game.new
         expect {
           game.play
         }.to output(
          %{Welcome to Mission Control!
Mission plan:
  Travel distance:    4.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    3,600 km/h
  Random seed:      34
What is the name of this mission? Engage afterburner? (Y/n) Release support structures? (Y/n) Perform cross-checks? (Y/n) Launch? (Y/n) Launched! Please wait for updates...
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 2.0 km
  Elapsed time: 0:00:02
  Time to destination: 0:00:02
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 3.0 km
  Elapsed time: 0:00:03
  Time to destination: 0:00:01
Mission completed!
Mission summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 0/0
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Would you like to run another mission? (Y/n) Mission plan:
  Travel distance:    4.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    3,600 km/h
  Random seed:      34
What is the name of this mission? Engage afterburner? (Y/n) Release support structures? (Y/n) Perform cross-checks? (Y/n) Launch? (Y/n) Launched! Please wait for updates...
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 2.0 km
  Elapsed time: 0:00:02
  Time to destination: 0:00:02
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 3.0 km
  Elapsed time: 0:00:03
  Time to destination: 0:00:01
Mission completed!
Mission summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 0/0
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Would you like to run another mission? (Y/n) All missions summary:
  Total distance traveled: 8.00 km
  Number of abort and retries: 0/0
  Number of explosions: 0
  Total fuel burned: 22,432 liters
  Flight time: 0:00:08
Bye bye! Hope you enjoyed it!
}
          ).to_stdout
      end
    end

    context 'when auto-aborting' do
      before(:each) do
        allow_any_instance_of(Mission::ChaosMonkey).to receive(:chaos_for_mission).and_return([1, no_error], [no_error, no_error])
      end

      it 'shows retry option for auto abort' do
        expect(Time).to receive(:now).and_return(0, 1, 2, 3, 4)
        allow($stdin).to receive(:gets).and_return(
          mission_name,
          yes_answer, # first mission plan (auto aborted)
          yes_answer, # retry
          yes_answer, yes_answer, yes_answer, yes_answer, # second mission plan
          no_answer # no more missions
        )

        game = MissionControl::Game.new
         expect {
           game.play
         }.to output(
          %{Welcome to Mission Control!
Mission plan:
  Travel distance:    4.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    3,600 km/h
  Random seed:      34
What is the name of this mission? Engage afterburner? (Y/n) Mission aborted!
Would you like to retry? (Y/n) Engage afterburner? (Y/n) Release support structures? (Y/n) Perform cross-checks? (Y/n) Launch? (Y/n) Launched! Please wait for updates...
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 2.0 km
  Elapsed time: 0:00:02
  Time to destination: 0:00:02
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 3.0 km
  Elapsed time: 0:00:03
  Time to destination: 0:00:01
Mission completed!
Mission summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 1/1
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Would you like to run another mission? (Y/n) All missions summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 1/1
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Bye bye! Hope you enjoyed it!
}
          ).to_stdout
      end

      it 'correctly accounts for user aborts' do
        expect(Time).to receive(:now).and_return(0, 1, 2, 3, 4)
        allow($stdin).to receive(:gets).and_return(
          mission_name,
          yes_answer, # first launch plan (auto aborted)
          yes_answer, # retry
          yes_answer, no_answer, # second launch plan (user aborted)
          yes_answer, # retry
          yes_answer, yes_answer, yes_answer, yes_answer, #third launch plan (complete)
          no_answer # no more missions
        )

        game = MissionControl::Game.new
        expect {
          game.play
        }.to output(
          %{Welcome to Mission Control!
Mission plan:
  Travel distance:    4.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    3,600 km/h
  Random seed:      34
What is the name of this mission? Engage afterburner? (Y/n) Mission aborted!
Would you like to retry? (Y/n) Engage afterburner? (Y/n) Release support structures? (Y/n) Mission aborted!
Would you like to retry? (Y/n) Engage afterburner? (Y/n) Release support structures? (Y/n) Perform cross-checks? (Y/n) Launch? (Y/n) Launched! Please wait for updates...
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 2.0 km
  Elapsed time: 0:00:02
  Time to destination: 0:00:02
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 3.0 km
  Elapsed time: 0:00:03
  Time to destination: 0:00:01
Mission completed!
Mission summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 2/2
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Would you like to run another mission? (Y/n) All missions summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 2/2
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Bye bye! Hope you enjoyed it!
}
          ).to_stdout
      end
    end

    context 'when exploding' do
      before(:each) do
        allow_any_instance_of(Mission::ChaosMonkey).to receive(:chaos_for_mission).and_return([no_error, 2], [no_error, no_error])
      end

      it 'shows an explosion message' do
        expect(Time).to receive(:now).and_return(0, 1, 2, 0, 1, 2, 3, 4)
        allow($stdin).to receive(:gets).and_return(
          mission_name,
          yes_answer, yes_answer, yes_answer, yes_answer, # first launch plan (auto exploded)
          yes_answer, # run another mission,
          anoter_mission_name,
          yes_answer, yes_answer, yes_answer, yes_answer, # second launch plan (complete)
          no_answer # no more missions
        )

        game = MissionControl::Game.new
        expect {
          game.play
        }.to output(
          %{Welcome to Mission Control!
Mission plan:
  Travel distance:    4.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    3,600 km/h
  Random seed:      34
What is the name of this mission? Engage afterburner? (Y/n) Release support structures? (Y/n) Perform cross-checks? (Y/n) Launch? (Y/n) Launched! Please wait for updates...
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 2.0 km
  Elapsed time: 0:00:02
  Time to destination: 0:00:02
Oops! Rocket exploded!
Mission summary:
  Total distance traveled: 2.00 km
  Number of abort and retries: 0/0
  Number of explosions: 1
  Total fuel burned: 5,608 liters
  Flight time: 0:00:02
Would you like to run another mission? (Y/n) Mission plan:
  Travel distance:    4.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    3,600 km/h
  Random seed:      34
What is the name of this mission? Engage afterburner? (Y/n) Release support structures? (Y/n) Perform cross-checks? (Y/n) Launch? (Y/n) Launched! Please wait for updates...
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 2.0 km
  Elapsed time: 0:00:02
  Time to destination: 0:00:02
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 3.0 km
  Elapsed time: 0:00:03
  Time to destination: 0:00:01
Mission completed!
Mission summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 0/0
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Would you like to run another mission? (Y/n) All missions summary:
  Total distance traveled: 6.00 km
  Number of abort and retries: 0/0
  Number of explosions: 1
  Total fuel burned: 16,824 liters
  Flight time: 0:00:06
Bye bye! Hope you enjoyed it!
}
          ).to_stdout
      end

      it 'works with retries' do
        expect(Time).to receive(:now).and_return(0, 1, 2, 0, 1, 2, 3, 4)
        allow($stdin).to receive(:gets).and_return(
          mission_name,
          yes_answer, yes_answer, yes_answer, yes_answer, # first launch plan (auto exploded)
          yes_answer, # run another mission,
          anoter_mission_name,
          yes_answer, no_answer, # second launch plan (aborted)
          yes_answer, # retry
          yes_answer, yes_answer, yes_answer, yes_answer, # third launch plan (complete)
          no_answer # no more missions
        )

        game = MissionControl::Game.new
        expect {
          game.play
        }.to output(
          %{Welcome to Mission Control!
Mission plan:
  Travel distance:    4.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    3,600 km/h
  Random seed:      34
What is the name of this mission? Engage afterburner? (Y/n) Release support structures? (Y/n) Perform cross-checks? (Y/n) Launch? (Y/n) Launched! Please wait for updates...
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 2.0 km
  Elapsed time: 0:00:02
  Time to destination: 0:00:02
Oops! Rocket exploded!
Mission summary:
  Total distance traveled: 2.00 km
  Number of abort and retries: 0/0
  Number of explosions: 1
  Total fuel burned: 5,608 liters
  Flight time: 0:00:02
Would you like to run another mission? (Y/n) Mission plan:
  Travel distance:    4.0 km
  Payload capacity: 50,000 kg
  Fuel capacity:    1,514,100 liters
  Burn rate:        168,240 liters/min
  Average speed:    3,600 km/h
  Random seed:      34
What is the name of this mission? Engage afterburner? (Y/n) Release support structures? (Y/n) Mission aborted!
Would you like to retry? (Y/n) Engage afterburner? (Y/n) Release support structures? (Y/n) Perform cross-checks? (Y/n) Launch? (Y/n) Launched! Please wait for updates...
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 2.0 km
  Elapsed time: 0:00:02
  Time to destination: 0:00:02
Mission status:
  Current fuel burn rate: 168,240 liters/min
  Current speed: 3,600 km/h
  Current distance traveled: 3.0 km
  Elapsed time: 0:00:03
  Time to destination: 0:00:01
Mission completed!
Mission summary:
  Total distance traveled: 4.00 km
  Number of abort and retries: 1/1
  Number of explosions: 0
  Total fuel burned: 11,216 liters
  Flight time: 0:00:04
Would you like to run another mission? (Y/n) All missions summary:
  Total distance traveled: 6.00 km
  Number of abort and retries: 1/1
  Number of explosions: 1
  Total fuel burned: 16,824 liters
  Flight time: 0:00:06
Bye bye! Hope you enjoyed it!
}
          ).to_stdout
      end
    end
  end
end