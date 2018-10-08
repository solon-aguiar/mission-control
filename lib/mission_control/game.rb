require_relative './unit'

module MissionControl
  class Game
    def initialize
      @control_panel = MissionControl::ControlPanel.new
      @localization = Localization.new(:en_US)
      @reporter = Reporter.new(@localization)

      @yes_no_options = {
            @localization.get_localized_string(:proceed) => :proceed,
            @localization.get_localized_string(:abort) => :abort
      }
      @invalid_input = @localization.get_localized_string(:invalid_input)
    end

    def play
      IO::Output.write_line(@localization.get_localized_string(:welcome))

      loop do
        play_new_round

        message = "#{@localization.get_localized_string(:new_mission_prompt)} (#{@yes_no_options.keys.join('/')})"
        new_round = IO::Input.get_option(message, @yes_no_options, @invalid_input)

        break unless new_round == :proceed
      end

      print_game_stats
    end

    private

    def play_new_round
      seed = Random.rand(100)
      IO::Output.write_line(@reporter.build_mission_plan(seed))

      message = @localization.get_localized_string(:new_mission_name)
      invalid_name = @localization.get_localized_string(:invalid_name)
      mission_name = IO::Input.get_mission_name(message, invalid_name)

      mission = @control_panel.create_mission(mission_name, seed)
      start(mission)

      IO::Output.write_line(@reporter.build_mission_summary(mission.summary))
    end

    def print_game_stats
      IO::Output.write_line(@reporter.build_missions_summary(@control_panel.all_summaries))
      IO::Output.write_line(@localization.get_localized_string(:bye))
    end

    def start(mission)
      mission.start_launch_plan!

      while !mission.ready_to_launch? && !mission.launch_plan_aborted?
        prompt = get_string_for_state(mission)
        options = get_options_for_state(mission)

        option = IO::Input.get_option(prompt, options, @invalid_input)
        mission.transition_launch_plan_to!(option)
      end

      if mission.launch_plan_aborted?
        IO::Output.write_line(@localization.get_localized_string(:aborted))

        message = "#{@localization.get_localized_string(:want_to_retry)} (#{@yes_no_options.keys.join('/')})"
        wants_retry = IO::Input.get_option(message, @yes_no_options, @invalid_input)

        if wants_retry == :proceed
          return start(mission)
        else
          return
        end
      end

      showed_start = false
      mission.launch_rocket!(Config::SLEEP_INTERVAL) do |current_stats|
        if !showed_start
          IO::Output.write_line(@localization.get_localized_string(:rocket_launched))
        elsif should_display_report(current_stats.elapsed_time.to_i)
          IO::Output.write_line(@reporter.build_mission_status(current_stats))
        end
        showed_start = true
      end

      if mission.flight_successful?
        IO::Output.write_line(@localization.get_localized_string(:mission_completed))
      else
        IO::Output.write_line(@localization.get_localized_string(:rocket_exploded))
      end
    end

    def get_string_for_state(mission)
      state = @localization.get_localized_string(mission.launch_plan_state)
      options = get_options_for_state(mission).keys.join('/')

      "#{state} (#{options})"
    end

    def get_options_for_state(mission)
      options = {}
      mission.launch_plan_transitions.reverse.map do |opt|
        localized_value = @localization.get_localized_string(opt)

        options[localized_value] = opt
      end

      options
    end

    def should_display_report(elapsed_time)
      elapsed_time != 0 && Unit.ms_to_se(elapsed_time).to_i % (Config::REPORT_INTERVAL) == 0
    end
  end
end
