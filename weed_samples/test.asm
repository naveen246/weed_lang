DEF_MAIN:
	READ_NUM n
	MOV n,@R0
	MOV @R0,-(SP)
	MOV #3,@R0
	ADD (SP)+,@R0
	MOV @R0,-(SP)
	MOV #1,@R0
	CMP (SP)+,@R0, <=
	JIF L0
	MOV #1,@R0
	WRITE_NUM @R0
	JMP L1
L0:
	MOV n,@R0
	MOV @R0,i
	MOV #1,@R0
	MOV @R0,f
L2:
	MOV i,@R0
	MOV @R0,-(SP)
	MOV #1,@R0
	CMP (SP)+,@R0, >
	JIF L3
	MOV f,@R0
	MOV @R0,-(SP)
	MOV i,@R0
	MUL (SP)+,@R0
	MOV @R0,f
	MOV i,@R0
	MOV @R0,-(SP)
	MOV #1,@R0
	SUB (SP)+,@R0
	MOV @R0,i
	JMP L2
L3:
	MOV f,@R0
	WRITE_NUM @R0
L1:
	END
