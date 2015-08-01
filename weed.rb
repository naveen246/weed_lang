require_relative 'log'
require_relative 'code_gen'

class Compiler
  
  def initialize
    @keywords = ["def", "if", "elsif", "else", "end", "while", "read_num", "read_str", "write_num", "write_str", "return", "break", "continue"]
    @token
    @cur_index = 0
    @cur_keyword = nil
    @char
    @symbol_table = {}
    @labels
    @code_gen = CodeGen.new
  end

  def get_char
    @char = @program[@cur_index]
    @cur_index += 1
  end

  def abort(msg)
    puts "Error: #{msg}"
    abort()
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
    while @char == /\s/ { get_char }
  end

  def read_token(expected_val, regex)
    skip_white_space
    expected(expected_val) if @char != regex
    @token = ''
    while @char == regex
      @token << @char
      get_char 	
    end
  end

  def read_name
  	read_token("Name", /\w/)
  	@keywords.include?(@token) ? @cur_keyword = @token : @cur_keyword = nil
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

  def compile(file)
    @program = File.read(file)
    get_char
    read_name
  end
end



























