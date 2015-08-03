DEF_MAIN:
	WRITE_STR Enter the number of terms
	READ_NUM n
	MOV #0,@R0
	MOV @R0,i
	MOV #0,@R0
	MOV @R0,first
	MOV #1,@R0
	MOV @R0,second
L0:
	MOV i,@R0
	MOV @R0,-(SP)
	MOV n,@R0
	CMP (SP)+,@R0, <
	JIF L1
	MOV i,@R0
	MOV @R0,-(SP)
	MOV #1,@R0
	CMP (SP)+,@R0, <=
	JIF L2
	MOV i,@R0
	WRITE_NUM @R0
	JMP L3
L2:
	MOV first,@R0
	MOV @R0,-(SP)
	MOV second,@R0
	ADD (SP)+,@R0
	MOV @R0,temp
	MOV second,@R0
	MOV @R0,first
	MOV temp,@R0
	MOV @R0,second
	MOV temp,@R0
	WRITE_NUM @R0
L3:
	MOV i,@R0
	MOV @R0,-(SP)
	MOV #1,@R0
	ADD (SP)+,@R0
	MOV @R0,i
	JMP L0
L1:
	END
