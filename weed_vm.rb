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
        params_str = instr.dup
        params_str.slice!(item).strip!
        params = params_str.split(',').map(&:strip)
        send(item.downcase, params) 
      end
    end  
  end

  def cmp(params)
    first_val = get_val(params[0])
    second_val = get_val(params[1])
    @reg[ACC] = eval("#{first_val} #{params[2]} #{second_val}")
    @log.write("cmp #{first_val} #{params[2]} #{second_val}")
    @log.write(@reg[ACC])
    @program_counter += 1
  end

  #jump if false
  def jif(params)
    if @reg[ACC]
      @program_counter += 1
    else
      @program_counter = @labels[params[0]]
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

  def math_op(params, op)
    @reg[ACC] = eval("#{get_num_val(params[0])} #{op} #{get_num_val(params[1])}")
    @program_counter += 1
  end

  def mul(params)
    math_op(params, "*")
  end

  def div(params)
    math_op(params, "/")
  end

  def mod(params)
    math_op(params, "%")
  end

  def add(params)
    math_op(params, "+")
  end

  def sub(params)
    math_op(params, "-")
  end

  def pow(params)
    math_op(params, "**")
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
    @local_vars[params[0]] = to_num(value)
    @program_counter += 1
  end

  def write(params)
    puts get_val(params[0])
    @program_counter += 1
  end

  def to_num(val)
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

  def get_num_val(str)
    to_num(get_val(str))
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