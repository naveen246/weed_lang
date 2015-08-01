
class CodeGen
  
  def emit_label(label)
    puts "#{label}:"
  end

  def emit_instr(instr)
    puts "\t#{instr}"
  end

  
end 