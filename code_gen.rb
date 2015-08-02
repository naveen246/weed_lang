
class CodeGen

  def initialize(file_name)
    file_name.gsub!(/\.\S*/, '')
    @asm_file_name = "#{file_name}.asm"
  end
  
  def emit_label(label)
    puts "#{label}:"
    File.open(@asm_file_name, "a") do |file|
      file.puts "#{label}:"
    end
  end

  def emit_instr(instr)
    puts "\t#{instr}"
    File.open(@asm_file_name, "a") do |file|
      file.puts "\t#{instr}"
    end
  end

  def compare(op)
    #Compare Top of Stack with Primary
    emit_instr("CMP (SP)+,D0")
  end

  def push
    #Push Primary onto Stack
    emit_instr("MOVE D0,-(SP)")
  end

  def pop_and
    #AND Top of Stack with Primary
    emit_instr("AND (SP)+,D0")
  end

  def pop_or
    #OR Top of Stack with Primary
    emit_instr("OR (SP)+,D0")
  end

  def pop_mul
    #Multiply Top of Stack by Primary
    emit_instr("MULS (SP)+,D0")
  end

  def pop_div
    #Divide Top of Stack by Primary
    emit_instr("MOVE (SP)+,D1")
    emit_instr("EXG D1,D0")
    emit_instr("DIVS D1,D0")
  end

  def pop_add
    #Add Top of Stack to Primary
    emit_instr("ADD (SP)+,D0")
  end
  
  def pop_sub
    #Subtract Primary from Top of Stack
    emit_instr("SUB (SP)+,D0")
    emit_instr("NEG D0")
  end

  def not_it
    #Complement the Primary Register
    emit_instr("NOT D0")
  end

  def load_const(val)
    #Load a Constant Value to Primary Register
    emit_instr("MOVE \##{val},D0")
  end

  def load_var(var)
    #Load a Variable to Primary Register
    emit_instr("MOVE #{var}(PC),D0")
  end

  def store(val)
    #Store Primary to Variable
    emit_instr("LEA #{val}(PC),A0")
    emit_instr("MOVE D0,(A0)")
  end

  def negate
    #Negate the Primary Register
    emit_instr("NEG D0")
  end

  def write
    #Write Variable from Primary Register
    emit_instr("BSR WRITE")
  end

  def read(value)
    #Read Variable to Primary Register
    emit_instr("BSR READ");
    store(value);
  end

  def branch_false(label)
    #Branch False
    emit_instr("TST D0")
    emit_instr("BEQ #{label}")
  end

  def branch(label)
    #Branch Unconditional
    emit_instr("BRA label")
  end

  def set_equal
    #Set D0 If Compare was =
    emit_instr("SEQ D0")
    emit_instr("EXT D0")
  end

  def set_not_equal
    #Set D0 If Compare was !=
    emit_instr("SNE D0")
    emit_instr("EXT D0")
  end

  def set_greater
    #Set D0 If Compare was >
    emit_instr("SLT D0")
    emit_instr("EXT D0")
  end

  def set_less
    #Set D0 If Compare was <
    emit_instr("SGT D0")
    emit_instr("EXT D0")
  end

  def set_less_or_equal
    #Set D0 If Compare was <=
    emit_instr("SGE D0")
    emit_instr("EXT D0")
  end

  def set_greater_or_equal
    #Set D0 If Compare was >=
    emit_instr("SLE D0")
    emit_instr("EXT D0")
  end
end 