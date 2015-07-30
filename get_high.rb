require_relative 'weed_vm'

vm = VM.new()
file = ARGV[0]
vm.run(file+".asm")
vm.save_state
vm.pop_fn_stack