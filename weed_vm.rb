require 'bigdecimal'

class VM
  :state
  acc = "@ACC"
  def initialize
    @reg = {}
    @global_vars = {}
    @local_vars = {}
    @stack = []
    @labels = {}
    @program_counter
  end

  def run(file)
    @program = File.readlines(file)
    get_labels
    puts @labels
    @program_counter = @labels["DEF_MAIN"]
    execute
  end

  def save_state
    @stack << @local_vars << @program_counter << :state.to_s
    puts "save_state", @stack
  end
  
  def pop_stack
    last_state_index = @stack.rindex(:state.to_s)
    @stack.slice!(last_state_index..@stack.size)
    @program_counter = @stack.pop
    @local_vars = @stack.pop
    puts "pop_stack", @stack
  end

  def execute
    instr = @program[@program_counter]
    while !instr.include? "END"
      parse_and_exec(instr)
      instr = @program[@program_counter]
    end
  end

  def get_labels
    @program.each_with_index do |line, index|
      if line.include? ":"
        @labels[line.tr(':', '').strip] = index + 1
      end
    end
  end

  def get_val(str)
    
  end  

  def parse_and_exec(instr)
    instr_set = ["CMP", "JIF", "MOV", "RET", "MUL", "DIV", "MOD", "ADD", "SUB", "POW" "JMP", "READ_STR", 
      "READ_NUM", "WRITE"]
    instr_set.each do |item|
    if instr.include? item
      instr.slice!(item).strip!
      params = instr.split(',').map(&:strip)
      send(item.downcase, params) 
    end    
  end

  def cmp(params)
    first_val = get_val(params[0])
    second_val = get_val(params[1])
    @reg[acc] = eval("#{first_val} #{params[2]} #{second_val}")
    @program_counter += 1
  end

  #jump if false
  def jif(params)
    if @reg[acc]
      @program_counter = @labels[params[0]]
    else
      @program_counter += 1
    end  
  end

  def mov(params)
    
  end

  def ret(params)
    pop_stack
  end

  def mul(params)
    @reg[acc] = params[0] * params[1]
    @program_counter += 1
  end

  def div(params)
    @reg[acc] = params[0] / params[1]
    @program_counter += 1
  end

  def mod(params)
    @reg[acc] = params[0] % params[1]
    @program_counter += 1
  end

  def add(params)
    @reg[acc] = params[0] + params[1]
    @program_counter += 1
  end

  def sub(params)
    @reg[acc] = params[0] - params[1]
    @program_counter += 1
  end

  def pow(params)
    @reg[acc] = params[0] ** params[1]
    @program_counter += 1
  end

  def jmp(params)
    save_state if(params[0].include? "DEF")
    @program_counter = @labels[params[0]]
  end

  def read_str(params)
    @local_vars[params[0]] = STDIN.gets.chomp
  end

  def read_num(params)
    value = STDIN.gets.chomp
    @local_vars[params[0]] = to_numeric(value)

  def write(params)
    puts params[0]
  end

  def to_numeric(val)
    num = BigDecimal.new(val.to_s)
    if num.frac == 0
      num.to_i
    else
      num.to_f
    end
  end
end

