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

puts "enter number"
n = gets.chomp
puts fact(n.to_i)

a = BigDecimal.new(256.to_s).frac
puts a

:@ACC