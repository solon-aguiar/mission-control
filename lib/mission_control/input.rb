require_relative './output'

module MissionControl::Input
  def self.get_option(message, options, invalid_prompt)
    loop do
      MissionControl::Output::write(message)
      option = $stdin.gets.chomp.strip
      return options[option] if options.has_key? option
      MissionControl::Output::write_line(invalid_prompt)
    end
  end

  def self.get_mission_name(message, invalid_prompt)
    loop do
      MissionControl::Output::write(message)
      response = $stdin.gets.chomp
      return response unless response.empty?
      MissionControl::Output::write_line(invalid_prompt)
    end
  end
end