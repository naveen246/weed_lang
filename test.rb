require 'bigdecimal'

def fact(n)
  return 1 if n <= 1
  i = n
  f = 1
  while i > 1
  	f *= i
  	i -= 1
  end
  f
end

instr = "WRITE_STR Enter Number"
item = "WRITE_STR"

params_str = instr.dup
params_str.slice!(item)
params = params_str.split(',').map(&:strip)
puts params.to_s