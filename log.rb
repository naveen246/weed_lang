
class Log
  def initialize(file_name)
  	@log = file_name
  end

  def write(str)
    File.open(@log, "a") do |file|
    file.puts str
    end
    puts str
  end
end