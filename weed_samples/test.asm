DEF_MAIN:
	MOVE #4,D0
	LEA 4(PC),A0
	MOVE D0,(A0)
	MOVE n(PC),D0
	MOVE D0,-(SP)
	MOVE #1,D0
	CMP (SP)+,D0
	SGE D0
	EXT D0
	TST D0
	BEQ L0
	MOVE #1,D0
	BSR WRITE
	BRA L1
L0:
	MOVE n(PC),D0
	LEA n(PC),A0
	MOVE D0,(A0)
	MOVE #1,D0
	LEA 1(PC),A0
	MOVE D0,(A0)
L2:
	MOVE i(PC),D0
	MOVE D0,-(SP)
	MOVE #1,D0
	CMP (SP)+,D0
	SLT D0
	EXT D0
	TST D0
	BEQ L3
	MOVE f(PC),D0
	MOVE D0,-(SP)
	MOVE i(PC),D0
	MULS (SP)+,D0
	LEA i(PC),A0
	MOVE D0,(A0)
	MOVE i(PC),D0
	MOVE D0,-(SP)
	MOVE #1,D0
	SUB (SP)+,D0
	NEG D0
	LEA 1(PC),A0
	MOVE D0,(A0)
	BRA L2
L3:
	MOVE f(PC),D0
	BSR WRITE
L1: