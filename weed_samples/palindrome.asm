DEF_MAIN:
	WRITE_STR Enter a number to check if it is a palindrome or not\n
	READ_NUM n
	MOV n,@R0
	MOV @R0,temp
	MOV #1,@R0
	MOV @R0,reverse
L0:
	MOV temp,@R0
	MOV @R0,-(SP)
	MOV #0,@R0
	CMP (SP)+,@R0, !=
	JIF L1
	MOV reverse,@R0
	MOV @R0,-(SP)
	MOV #10,@R0
	MUL (SP)+,@R0
	MOV @R0,reverse
	MOV reverse,@R0
	MOV @R0,-(SP)
	MOV temp,@R0
	MOV @R0,-(SP)
	MOV #10,@R0
	MOD (SP)+, @R0
	ADD (SP)+,@R0
	MOV @R0,reverse
	MOV temp,@R0
	MOV @R0,-(SP)
	MOV #10,@R0
	DIV (SP)+, @R0
	MOV @R0,temp
	JMP L0
L1:
	MOV n,@R0
	WRITE_NUM @R0
	MOV n,@R0
	MOV @R0,-(SP)
	MOV reverse,@R0
	CMP (SP)+,@R0, ==
	JIF L2
	WRITE_STR  is a palindrome number
	JMP L3
L2:
	WRITE_STR  is not a palindrome number
L3:
	END
