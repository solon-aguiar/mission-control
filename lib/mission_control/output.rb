module MissionControl::Output
  def self.write(s)
    print s
  end

  def self.write_line(s)
    puts s
  end
end