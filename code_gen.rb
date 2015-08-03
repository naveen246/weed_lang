
class CodeGen

  def initialize(file_name)
    file_name.gsub!(/\.\S*/, '')
    @asm_file_name = "#{file_name}.asm"
    File.delete(@asm_file_name) if File.exist?(@asm_file_name)
  end
  
  def emit_label(label)
    File.open(@asm_file_name, "a") do |file|
      file.puts "#{label}:"
    end
  end

  def emit_instr(instr)
    File.open(@asm_file_name, "a") do |file|
      file.puts "\t#{instr}"
    end
    File.open("logs/parse_log", "a") do |file|
      file.puts "\t\t\t\t\t\t\t\t#{instr}"
    end
  end

  def compare(op)
    #Compare Top of Stack with Primary
    emit_instr("CMP (SP)+,@R0, #{op}")
  end

  def push
    #Push Primary onto Stack
    emit_instr("MOV @R0,-(SP)")
  end

  def pop_and
    #AND Top of Stack with Primary
    emit_instr("AND (SP)+,@R0")
  end

  def pop_or
    #OR Top of Stack with Primary
    emit_instr("OR (SP)+,@R0")
  end

  def pop_mul
    #Multiply Top of Stack by Primary
    emit_instr("MUL (SP)+,@R0")
  end

  def pop_div
    #Divide Top of Stack by Primary
    emit_instr("DIV (SP)+, @R0")
  end

  def pop_add
    #Add Top of Stack to Primary
    emit_instr("ADD (SP)+,@R0")
  end
  
  def pop_sub
    #Subtract Primary from Top of Stack
    emit_instr("SUB (SP)+,@R0")
  end

  def not_it
    #Complement the Primary Register
    emit_instr("NOT @R0")
  end

  def load_const(val)
    #Load a Constant Value to Primary Register
    emit_instr("MOV \##{val},@R0")
  end

  def load_var(var)
    #Load a Variable to Primary Register
    emit_instr("MOV #{var},@R0")
  end

  def store(var)
    #Store Primary to Variable
    emit_instr("MOV @R0,#{var}")
  end

  def negate
    #Negate the Primary Register
    emit_instr("NEG @R0")
  end

  def write_num
    #Write Variable from Primary Register
    emit_instr("WRITE_NUM @R0")
  end

  def write_str(str)
    emit_instr("WRITE_STR #{str}")
  end

  def read_num(value)
    #Read Variable to Primary Register
    emit_instr("READ_NUM #{value}")
  end

  def read_str(value)
    emit_instr("READ_STR #{value}")
  end

  def branch_false(label)
    #Branch False
    emit_instr("JIF #{label}")
  end

  def branch(label)
    #Branch Unconditional
    emit_instr("JMP #{label}")
  end

  def end
    emit_instr("END")
  end
end 