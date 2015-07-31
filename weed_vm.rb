
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
    get_labels
    puts @labels
    @program_counter = @labels["MAIN"]
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
    instr = @program[@program_counter]
    return if instr.include? "END"
    parse_and_exec(instr)
    execute    
  end

  def get_labels
    @program.each_with_index do |line, index|
      if line.include? ":"
        @labels[line.tr(':', '').strip] = index + 1
      end
    end
  end

  def parse_and_exec(instr)
    
  end
end

