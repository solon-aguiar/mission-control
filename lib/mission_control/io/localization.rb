class Localization
  @@TRANSLATIONS = {
      :en_US => {
        # greetings
        :welcome => 'Welcome to Mission Control!',
        :bye => 'Bye bye! Hope you enjoyed it!',

        # responses
        :proceed => 'Y',
        :abort => 'n',

        # prompts
        :new_mission_prompt => 'Would you like to run another mission?',
        :new_mission_name => 'What is the name of this mission?',
        :want_to_proceed => 'Would you like to proceed?',
        :want_to_retry => 'Would you like to retry?',
        :invalid_input => 'Please provide a valid value!',
        :invalid_name => 'Please provide a non-empty mission name!',

        # launch plan stages
        :afterburner => 'Engage afterburner?',
        :disengaging => 'Release support structures?',
        :cross_checking => 'Perform cross-checks?',
        :launching => 'Launch?',
        :rocket_launched => 'Launched! Please wait for updates...',

        # mission plan
        :mission_plan => 'Mission plan:',
        :travel_distance => "Travel distance: %s km",
        :payload_capacity => "Payload capacity: %s kg",
        :fuel_capacity => "Fuel capacity: %s liters",
        :burn_rate => "Burn rate: %s liters/min",
        :average_speed => "Average speed: %s km/h",
        :random_seed => "Random seed: %s",

        # mission summary
        :mission_summary => 'Mission summary:',
        :total_distance => "Total distance traveled: %s km",
        :retries_abort_no => "Number of abort and retries: %s",
        :no_explosions => "Number of explosions: %s",
        :total_fuel_burnt => "Total fuel burned: %s liters",
        :flight_time => "Flight time: %s",

        # mission status
        :mission_status => 'Mission status:',
        :fuel_burn_rate => "Current fuel burn rate: %s liters/min",
        :current_speed => "Current speed: %s km/h",
        :current_distance => "Current distance traveled: %s km",
        :elapsed_time => "Elapsed time: %s",
        :time_left => "Time to destination: %s",

        # final messages
        :aborted => 'Mission aborted!',
        :rocket_exploded => 'Oops! Rocket exploded!',
        :mission_completed => 'Mission completed!'
      }
    }
    attr_accessor :locale

    def initialize(default_locale)
      @default_locale = default_locale
      @locale = default_locale
    end

    def get_localized_string(key, *args)
      lang = @@TRANSLATIONS.has_key?(@locale) ? @@TRANSLATIONS[@locale] : @@TRANSLATIONS[@default_locale]
      return nil unless lang

      lang.has_key?(key) ? lang[key] % args : nil
    end

  def format_integer(number)
    number.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse
  end

  def format_float(number, decimal_places=2)
    "%.#{decimal_places}f" % number
  end

  def format_time(milliseconds)
    secs, milisecs = milliseconds.divmod(1000)
    mins, secs = secs.divmod(60)
    hours, mins = mins.divmod(60)

    "#{hours}:#{[mins,secs].map { |e| e.to_s.rjust(2,'0') }.join(':')}"
  end
end