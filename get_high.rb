require_relative 'weed'
require_relative 'weed_vm'


compiler = Compiler.new()
vm = VM.new()
file = ARGV[0].gsub(/\.\S*/, '')
compiler.compile(file+".rb")
vm.run(file+".asm")
