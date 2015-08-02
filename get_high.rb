require_relative 'weed_parser'
require_relative 'weed_vm'


parser = Parser.new()
vm = VM.new()
file = ARGV[0].gsub(/\.\S*/, '')
#parser.parse(file+".weed")
vm.run(file+".asm")
