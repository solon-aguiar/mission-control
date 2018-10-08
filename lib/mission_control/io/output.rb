module IO::Output
  def self.write(str)
    print str
  end

  def self.write_line(line)
    puts line
  end
end
