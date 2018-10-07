require_relative './output'

module IO::Input
  def self.get_option(message, options, invalid_prompt)
    loop do
      IO::Output::write("#{message} ")
      option = $stdin.gets.chomp.strip
      return options[option] if options.has_key? option
      IO::Output::write_line(invalid_prompt)
    end
  end

  def self.get_mission_name(message, invalid_prompt)
    loop do
      IO::Output::write("#{message} ")
      response = $stdin.gets.chomp
      return response unless response.strip.empty?
      IO::Output::write_line(invalid_prompt)
    end
  end
end