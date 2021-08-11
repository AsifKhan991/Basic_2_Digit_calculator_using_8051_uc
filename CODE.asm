;Date Created: 7th AUGUST, 2021
;Owner: Md Asifuzzaman Khan
;Inst:Islamic university of Technology(IUT),OIC
;Project: 2 digit decimal Calculator based on AT89C51
;Course: EEE4706

ORG 00H
RS EQU P3.0
RW EQU P3.1
E EQU P3.2

N1 EQU 50H ;HOLDS 1ST NUMBER
N2 EQU 51H ;HOLDS 2ND NUMBER
OP EQU 52H ;HOLDS OPERATOR SIGN

MOV SP,#70H
MOV PSW,#00H

START:
MOV R0,#0 ; TO KEEP TRACK OF INPUT
LCALL CLEAR_GOTO1


MOV A,#0FH
MOV P2,A
K1: MOV P2,#00001111B
MOV A,P2
ANL A,#00001111B
CJNE A,#00001111B,K1
K2: ACALL DELAY
MOV A,P2
ANL A,#00001111B
CJNE A,#00001111B,OVER
SJMP K2
OVER: ACALL DELAY
MOV A,P2
ANL A,#00001111B
CJNE A,#00001111B,OVER1
SJMP K2
OVER1: 
MOV P2,#11101111B
MOV A,P2
ANL A,#00001111B
CJNE A,#00001111B,ROW_0

MOV P2,#11011111B  
MOV A,P2
ANL A,#00001111B
CJNE A,#00001111B,ROW_1 
  
MOV P2,#10111111B 
MOV A,P2
ANL A,#00001111B
CJNE A,#00001111B,ROW_2

MOV P2,#01111111B
MOV A,P2
ANL A,#00001111B
CJNE A,#00001111B,ROW_3
LJMP K2

ROW_0: MOV DPTR,#KCODE0
SJMP FIND
ROW_1: MOV DPTR,#KCODE1
SJMP FIND
ROW_2: MOV DPTR,#KCODE2
SJMP FIND
ROW_3: MOV DPTR,#KCODE3

FIND: 
RRC A
JNC MATCH
INC DPTR
SJMP FIND

MATCH: CLR A
MOVC A,@A+DPTR
CJNE A, #99H, ON_AC
LJMP START

ON_AC: 
ACALL DATAWRT
ACALL DELAY

CJNE A,#'=',CONTINUE
LCALL DO_OP

CONTINUE:
LCALL TAKEINPUT
LJMP K1



;---------------------------------------ALL THE FUNCTIONS ARE DECLARED HERE----------------------------------------
TAKEINPUT:
CLR C 
SUBB A,#48     

;TAKES FIRST DIGIT OF FIRST NUMBER
INC R0 ;KEEPS INCREMENTING R0 AS INPUTS ARE TAKEN, FINAL NUMBER WILL 5 AFTER ALL INPUTS GIVEN
CJNE R0,#1,D2  ;TAKES SECOND DIGIT OF FIRST NUMBER
MOV R1,A
D2: CJNE R0,#2,OPERATOR
MOV R2,A
LCALL FORMAT_INPUT_DIGITS
MOV N1,A

OPERATOR: CJNE R0,#3,D3 ; ;TAKES SIGN
ADD A,#48
MOV OP,A

D3: CJNE R0,#4,D4    ;TAKES FIRST DIGIT OF SECOND NUMBER
MOV R1,A
D4: CJNE R0,#5,GOBACK ;TAKES SECOND DIGIT OF SECOND NUMBER (I.E: 42+02 TOTAL 5 INPUTS INCLUDING THE SIGN)
MOV R2,A
LCALL FORMAT_INPUT_DIGITS
MOV N2,A

GOBACK:
RET

FORMAT_INPUT_DIGITS: ;CONVERTS TO 2 DIGIT DECIMAL NUMBER (N=R1*10+R2)=R1R2D
MOV A,R1
MOV B,#10
MUL AB
ADD A,R2
RET

DO_OP:  ;SELECTS WHICH OPERATION TO BE DONE BASED ON THE SAVED SIGN VARIABLE IN OP
MOV A,OP
CJNE A,#'+',MN
LCALL ADDITION
MN:CJNE A,#'-',D
LCALL SUBTRACT
D:CJNE A,#'/',MU
LCALL DIVIDE
MU:CJNE A,#'*',DONE
LCALL MULTIPLY
DONE:
RET

ADDITION:
CLR C
MOV A,N1
MOV B,N2
ADD A,B
MOV R6,#0
MOV R7,A
LCALL PRINT_IN_BCD
RET

SUBTRACT:
CLR C
MOV A,N1
MOV B,N2
SUBB A,B
JNC PASS
MOV R5,A
MOV A,#'-'
LCALL DATAWRT
MOV A,R5
CPL A
INC A
PASS:
MOV R6,#0
MOV R7,A
LCALL PRINT_IN_BCD
RET

MULTIPLY:
CLR C
MOV A,N1
MOV B,N2
MUL AB
MOV R7,A
MOV R6,B
LCALL PRINT_IN_BCD
RET

DIVIDE:
CLR OV
CLR C
MOV A,N1
MOV B,N2
DIV AB
JNB OV,NO_E  ;IF OVERFLOW OCCOURS PRINT 'E' AS ERROR i.e:42/00=E
MOV A,#'E'
LCALL DATAWRT
RET
NO_E:
MOV R6,#0
MOV R7,A
LCALL PRINT_IN_BCD
RET

PRINT_IN_BCD:
MOV R5,#0
MOV R4,#0
MOV R2,#16 ; TO PROCESS 16 BITS

BIN_10:
MOV A,R7 ; BIN16 = BIN16 * 2
ADD A,R7
MOV R7,A

MOV A,R6
ADDC A,R6 ; CARRY = MSB of BIN16
MOV R6,A

MOV A,R5 ; BCD = BCD * 2 + CARRY
ADDC A,R5
DA A
MOV R5,A

MOV A,R4
ADDC A,R4
DA A
MOV R4,A

DJNZ R2,BIN_10

MOV A,R4 ;FROM THIS POINT THE 4 DIGITS IN R4(MSB) & R5(LSB) GETS PRINTED IN DECIMAL
SWAP A  ;SWAP IS USED TO CONSIDER ONLY THE LOWER NIBBLE AS BCD 
ANL A,#0FH
ADD A,#48
LCALL DATAWRT
MOV A,R4
ANL A,#0FH
ADD A,#48
LCALL DATAWRT
MOV A,R5
SWAP A
ANL A,#0FH
ADD A,#48
LCALL DATAWRT
MOV A,R5
ANL A,#0FH
ADD A,#48
LCALL DATAWRT
RET


CLEAR_GOTO1: 
MOV A,#38H
LCALL COMNWRT
LCALL DELAY
MOV A,#0FH
LCALL COMNWRT
LCALL DELAY
MOV A,#01
LCALL COMNWRT
LCALL DELAY
MOV A,#06H
LCALL COMNWRT
LCALL DELAY
MOV A,#80H
LCALL COMNWRT
LCALL DELAY
RET


COMNWRT:
LCALL READY
MOV P1,A
CLR RS
CLR RW
SETB E
ACALL DELAY
CLR E
RET

DATAWRT: LCALL READY
MOV P1,A
SETB RS
CLR RW
SETB E
ACALL DELAY
CLR E
RET

READY: SETB P1.7
CLR RS
SETB RW
WAIT: CLR E
LCALL DELAY
SETB E
JB P1.7,WAIT
RET


DELAY: 
SETB PSW.3
MOV R3,#10
HERE2: MOV R4,#100
HERE: DJNZ R4,HERE
DJNZ R3,HERE2
CLR PSW.3
RET

;ASCII LOOK-UP TABLE FOR EACH ROW
KCODE0: DB '7','8','9','/' ;ROW 0
KCODE1: DB '4','5','6','*' ;ROW 1
KCODE2: DB '1','2','3','-' ;ROW 2
KCODE3: DB 99H,'0','=','+' ;ROW 3
END
