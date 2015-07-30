
class VM
  :state
  def initialize
    @reg = []
    @acc
    @global_vars = {}
    @local_vars = {}
    @fn_stack = []
    @labels = {}
    @program_counter
  end

  def run(file)
    @program = File.readlines(file)
    puts @program
    execute
  end

  def save_state
    @fn_stack << @local_vars << @program_counter << :state.to_s
    puts "save_state", @fn_stack
  end
  
  def pop_fn_stack
    last_state_index = @fn_stack.rindex(:state.to_s)
    @fn_stack.slice!(last_state_index..@fn_stack.size)
    @program_counter = @fn_stack.pop
    @local_vars = @fn_stack.pop
    puts "pop_fn_stack", @fn_stack
  end

  def execute
    get_labels
    puts @labels   
  end

  def get_labels
    @program.each_with_index do |line, index|
      if line.include? ":"
        @labels[line.tr(':', '').strip] = index + 1
      end
    end
  end

  def move(source, var)
    @variables[var] = source
  end

end

