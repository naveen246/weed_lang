require 'bigdecimal'
require_relative 'log'

class VM
  :state
  ACC = "@R0"
  def initialize
    @reg = {}
    @global_vars = {}
    @local_vars = {}
    @fn_stack = []
    @stack = []
    @labels = {}
    @program_counter
    @log = Log.new("logs/vm_log")
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
      get_next_instruction
    elsif instr.include? "END"
      nil
    else
      instr
    end
  end

  def run(file)
    @program = File.readlines(file)
    get_labels
    @log.write(@labels)
    @program_counter = @labels["DEF_MAIN"]
    step_through
  end

  def step_through
    @log.write("step_through")
    instr = get_next_instruction
    while instr.to_s != ''
      parse_and_exec(instr)
      instr = get_next_instruction
    end
  end  

  def parse_and_exec(instr)
    @log.write("parse_and_exec " + instr)
    instr_set = ["CMP", "JIF", "MOV", "RET", "MUL", "DIV", "MOD", "ADD", "SUB", "POW", "AND", "OR", "NOT", "NEG",
     "JMP", "READ_STR", "READ_NUM", "WRITE_STR", "WRITE_NUM"]
    instr_set.each do |item|
      if instr.include? item
        @log.write(item)
        params_str = instr.dup
        params_str.slice!(item)
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
    @reg[ACC] ? @program_counter += 1 : @program_counter = @labels[params[0]]
  end

  def mov(params)
    value = get_val(params[0])
    destn = params[1]
    destn.include?("@") ? @reg[destn] = value : @local_vars[destn] = value
    @stack.push(value) if destn.downcase.include?("(sp)")
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

  def and(params)
    first_val = get_val(params[0])
    second_val = get_val(params[1])
    @reg[ACC] = eval("#{first_val} && #{second_val}")
    @program_counter += 1
  end

  def or(params)
    first_val = get_val(params[0])
    second_val = get_val(params[1])
    @reg[ACC] = eval("#{first_val} || #{second_val}")
    @program_counter += 1
  end

  def not(params)
    @reg[params[0]] = !get_val(params[0])
  end

  def neg(params)
    @reg[params[0]] = -get_val(params[0])
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

  def write_str(params)
    params.each { |item| puts item }
    @program_counter += 1
  end

  def write_num(params)
    puts get_val(params[0])
    @program_counter += 1
  end

  def to_num(val)
    num = BigDecimal.new(val.to_s)
    num.frac == 0 ? num.to_i : num.to_f
  end

  def get_val(str)
    if str.include? "@"
      @reg[str]
    elsif str.include? "#"
      str.slice! "#"
      str
    elsif str.downcase.include? "(sp)"
      @stack.pop
    else
      @local_vars[str]
    end
  end

  def get_num_val(str)
    to_num(get_val(str))
  end

  def save_state
    @fn_stack << @local_vars << @program_counter + 1 << :state.to_s
    @log.write("save_state " + @fn_stack.to_s)
  end
  
  def pop_stack
    last_state_index = @fn_stack.rindex(:state.to_s)
    @fn_stack.slice!(last_state_index..@fn_stack.size)
    @program_counter = @fn_stack.pop
    @local_vars = @fn_stack.pop
    @log.write("pop_stack " + @fn_stack.to_s)
  end
end