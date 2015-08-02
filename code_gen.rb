
class CodeGen
  
  def emit_label(label)
    puts "#{label}:"
  end

  def emit_instr(instr)
    puts "\t#{instr}"
  end

  def compare
  end

  def push
  end

  def pop_and
  end

  def pop_or
  end

  def pop_mul
  end

  def pop_div
  end

  def pop_add
  end

  def pop_sub
  end

  def not_it
  end

  def load_const(val)
  end

  def load_var(var)
  end

  def store(val)
  end

  def negate
  end

  def write
  end

  def read
  end

  def branch_false(label)
  end

  def branch(label)
  end
end 