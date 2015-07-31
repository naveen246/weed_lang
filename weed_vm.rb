require 'bigdecimal'
require_relative 'log'

class VM
  :state
  ACC = "@ACC"
  def initialize
    @reg = {}
    @global_vars = {}
    @local_vars = {}
    @stack = []
    @labels = {}
    @program_counter
    @log = Log.new
  end

  def get_labels
    @program.each_with_index do |line, index|
      if line.include? ":"
        @labels[line.tr(':', '').strip] = index + 1
      end
    end
  end

  def get_next_instruction
    instr = @program[@program_counter]
    if instr.include? ":"
      @program_counter += 1
      return get_next_instruction
    elsif instr.include? "END"
      return nil
    else
      return instr
    end
  end

  def run(file)
    @program = File.readlines(file)
    get_labels
    @log.write(@labels)
    @program_counter = @labels["DEF_MAIN"]
    execute
  end

  def execute
    @log.write("execute")
    instr = get_next_instruction
    while instr.to_s != ''
      parse_and_exec(instr)
      instr = get_next_instruction
    end
  end  

  def parse_and_exec(instr)
    @log.write("parse_and_exec " + instr)
    instr_set = ["CMP", "JIF", "MOV", "RET", "MUL", "DIV", "MOD", "ADD", "SUB", "POW", "JMP", "READ_STR", 
      "READ_NUM", "WRITE"]
    instr_set.each do |item|
      if instr.include? item
        @log.write(item)
        instr.slice!(item).strip!
        params = instr.split(',').map(&:strip)
        send(item.downcase, params) 
      end
    end  
  end

  def cmp(params)
    first_val = get_val(params[0])
    second_val = get_val(params[1])
    @reg[ACC] = eval("#{first_val} #{params[2]} #{second_val}")
    @program_counter += 1
  end

  #jump if false
  def jif(params)
    if @reg[ACC]
      @program_counter = @labels[params[0]]
    else
      @program_counter += 1
    end  
  end

  def mov(params)
    value = get_val(params[0])
    destn = params[1]
    if destn.include? "@"
      @reg[destn] = value
    else
      @local_vars[destn] = value
    end
    @program_counter += 1
  end

  def ret(params)
    pop_stack
  end

  def mul(params)
    @reg[ACC] = params[0] * params[1]
    @program_counter += 1
  end

  def div(params)
    @reg[ACC] = params[0] / params[1]
    @program_counter += 1
  end

  def mod(params)
    @reg[ACC] = params[0] % params[1]
    @program_counter += 1
  end

  def add(params)
    @reg[ACC] = params[0] + params[1]
    @program_counter += 1
  end

  def sub(params)
    @reg[ACC] = params[0] - params[1]
    @program_counter += 1
  end

  def pow(params)
    @reg[ACC] = params[0] ** params[1]
    @program_counter += 1
  end

  def jmp(params)
    save_state if(params[0].include? "DEF")
    @program_counter = @labels[params[0]]
  end

  def read_str(params)
    @local_vars[params[0]] = STDIN.gets.chomp
    @program_counter += 1
  end

  def read_num(params)
    value = STDIN.gets.chomp
    @local_vars[params[0]] = to_numeric(value)
    @program_counter += 1
  end

  def write(params)
    puts params[0]
    @program_counter += 1
  end

  def to_numeric(val)
    num = BigDecimal.new(val.to_s)
    if num.frac == 0
      num.to_i
    else
      num.to_f
    end
  end

  def get_val(str)
    if str.include? "@"
      return @reg[str]
    elsif str.include? "#"
      str.slice! "#"
      return str  
    else
      return @local_vars[str]
    end
  end

  def save_state
    @stack << @local_vars << @program_counter + 1 << :state.to_s
    @log.write("save_state " + @stack.to_s)
  end
  
  def pop_stack
    last_state_index = @stack.rindex(:state.to_s)
    @stack.slice!(last_state_index..@stack.size)
    @program_counter = @stack.pop
    @local_vars = @stack.pop
    @log.write("pop_stack " + @stack.to_s)
  end
end