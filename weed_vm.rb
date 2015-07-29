
class VM
  :state
  def initialize
    @data_registers = { d0: nil, d1: nil, d2: nil, d3: nil }
    @address_registers = { a0: nil, a1: nil, a2: nil, a3: nil }
    @variables = {}
    @stack = []
  end

  def run(file)
    @program = File.readlines(file)
    puts @program
    @program.each do |line|
      execute(line)  
    end	
  end

  def save_state
    @stack << @variables << @address_registers << @data_registers << :state.to_s
    puts "save_state", @stack
  end
  
  def revert_to_previous_state
    last_state_index = @stack.rindex(:state.to_s)
    @stack.slice!(last_state_index..@stack.size)
    @data_registers = @stack.pop
    @address_registers = @stack.pop
    @variables = @stack.pop
    puts "revert_to_previous_state", @stack
  end

  def execute(line)
      
  end

  def clear(register)
    @data_registers[register.downcase.to_sym] = nil
  end

  def move(source, destination)
    @data_registers[reg.downcase.to_sym] = data
  end

end

