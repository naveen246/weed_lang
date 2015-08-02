require_relative 'log'
require_relative 'code_gen'

class Parser
  
  def initialize
    @keywords = ["def", "if", "else", "end", "while", "read", "write", "return", "break", "continue"]
    @token
    @cur_index = 0
    @cur_keyword = nil
    @char
    @symbol_table = {}
    @labels = []
    @code_gen = CodeGen.new
    @log = Log.new("parse_log")
  end

  def get_char
    @char = @program[@cur_index]
    @log.write("#{@cur_index} #{@char}")
    @cur_index += 1
  end

  def abort(msg)
    puts "Error: #{msg} @#{@cur_index}"
    exit(false)
  end

  def expected(token)
  	abort("#{token} expected")
  end

  def add_entry(name, type)
    abort("Duplicate identifier #{name}") if symbol_table.has_key?(name)
    symbol_table[name] = type
  end

  def undefined
    abort("undefined identifier")
  end

  def skip_white_space
    while @char =~ /\s/
      get_char
    end
  end

  def read_token(expected_val, regex)
    skip_white_space
    expected(expected_val) if !@char =~ regex
    @token = ''
    while @char =~ regex
      @token << @char
      get_char 	
    end
    skip_white_space
  end

  def read_name
  	read_token("Name", /\w/)
    @log.write("read_name token: #{@token}")
  end

  def read_number
    read_token("Number", /\d/)
  end

  def match_string(str)
    expected(str) if @token != str
  end

  def match_char(c)
    skip_white_space
    @char == c ? get_char : expected(c)
  end  

  def is_letter?(lookAhead)
    lookAhead =~ /[[:alpha:]]/
  end

  def is_numeric?(lookAhead)
    lookAhead =~ /[[:digit:]]/
  end

  def is_add_op?(c)
    c == '+' || c == '-'
  end

  def is_mul_op?(c)
    c == '*' || c == '/'
  end

  def is_rel_op?(c)
    ops = ['=', '!', '<', '>']
    ops.include? c
  end

  def match_relational_ops(op)
    op.each { |item| match_char(item) }
    expression
    code_gen.compare
  end

  def equals
    match_relational_ops(['=', '='])
  end

  def not_equals
    match_relational_ops(['!', '='])
  end

  def less_or_equal
    match_relational_ops(['<', '='])
  end 

  def greater_or_equal
    match_relational_ops(['>', '='])
  end

  def less
    match_char('<')
    if @char == "="
      less_or_equal
    else
      expression
      code_gen.compare
    end
  end

  def greater
    match_char('>')
    if @char == "="
      greater_or_equal
    else
      expression
      code_gen.compare
    end
  end

  def relation
    expression
    while is_rel_op?(@char)
      code_gen.push
      case @char
      when '=' then equals
      when '!' then not_equals
      when '<' then less
      when '>' then greater
      end
    end
  end

  def not_factor
    if @char == '!'
      match_char('!')
      relation
      code_gen.not_it
    else
      relation
    end
  end

  def bool_term
    not_factor
    while @char == '&'
      code_gen.push
      match_char('&')
      match_char('&')
      not_factor
      code_gen.pop_and
    end
  end

  def bool_or
    match_char('|')
    match_char('|')
    bool_term
    code_gen.pop_or
  end

  def bool_expression
  	bool_term
    while @char == '|'
      code_gen.push
      bool_or
    end
  end

  def alloc()
    add_entry(@token, 'v')
    if @char == '=='
      match_char('=')
      match_char('=')
      match_char('-') if @char == '-'
      read_number
    end
  end

  def data_decl
    read_name
    alloc
    while @char == ','
      match_char(',')
      read_number
      alloc
    end
  end

  def factor
    if @char == '('
      match_char('(')
      bool_expression
      match_char(')')
    elsif is_numeric? @char
      read_number
      code_gen.load_const(@token)
    else
      read_name
      code_gen.load_var(@token)
    end
  end

  def neg_factor
    match_char('-')
    if is_numeric? @char
      read_number
      code_gen.load_const(@token)
    else
      factor
    end
    code_gen.negate
  end

  def first_factor
    if is_add_op? @char
      if @char == '+'
        match_char('+')
        factor
      elsif @char == '-'
        neg_factor
      end
    else
      factor  
    end
  end

  def multiply
    match_char('*')
    factor
    code_gen.pop_mul
  end

  def divide
    match_char('/')
    factor
    code_gen.pop_div
  end

  def next_term
    while is_mul_op? @char
      code_gen.push
      if @char == '*' then multiply
      elsif  @char == '/' then divide
      end      
    end
  end

  def term
    factor
    next_term
  end

  def first_term
    first_factor
    next_term
  end

  def add
    match_char('+')
    factor
    code_gen.pop_add
  end

  def subtract
    match_char('-')
    factor
    code_gen.pop_sub
  end

  def expression
    first_term
    while is_add_op? @char
      code_gen.push
      if @char == '+' then add
      elsif  @char == '-' then subtract
      end      
    end
  end

  def read_write
    match_char('(')
    yield
    while @char == ','
      match_char(',')
      yield
    end  
    match_char(')')
  end

  def do_write
    read_write do
      expression
      code_gen.write
    end
  end

  def do_read
    read_write do
      read_name
      code_gen.read
    end
  end

  def new_label
    @labels << "L#{@labels.size}"
    @labels.last
  end

  def do_while
    l1 = new_label
    l2 = new_label
    code_gen.emit_label(l1)
    bool_expression
    code_gen.branch_false(l2)
    block
    match_string("end")
    code_gen.branch(l1)
    code_gen.emit_label(l2)
  end

  def do_if
    l1 = new_label
    l2 = l1
    bool_expression
    code_gen.branch_false(l1)
    block
    if @token == "else"
      l2 = new_label
      code_gen.branch(l2)
      code_gen.emit_label(l1)
      block
    end
    code_gen.emit_label(l2)
    match_string("end")
  end

  def assignment
    match_char('=')
    bool_expression
    code_gen.store(@token)
  end

  def block
    read_name
    while @token != "end" && @token != "else"
      case @token
      when "if" then do_if
      when "while" then do_while
      when "read" then do_read
      when "write" then do_write
      else assignment  
      end
    end
  end

  def main
    read_name
    match_string("main")
    match_char('(')
    match_char(')')
    block
    match_string("end")
  end

  def parse(file)
    @program = File.read(file)
    get_char
    read_name
    main if @token == "def"
  end
end



























