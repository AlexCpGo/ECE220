;
; The code given to you here implements the histogram calculation that 
; we developed in class.  In programming video lecture, we will discuss 
;  how to prints a number in hexadecimal to the monitor.
;
; Your assignment for this program is to combine these two pieces of 
; code to print the histogram to the monitor.
;
; If you finish your program, 
;    ** Submit a working version to Gradescope  **



	.ORIG	x3000		; starting address is x3000


;
; Count the occurrences of each letter (A to Z) in an ASCII string 
; terminated by a NUL character.  Lower case and upper case should 
; be counted together, and a count also kept of all non-alphabetic 
; characters (not counting the terminal NUL).
;
; The string starts at x4000.
;
; The resulting histogram (which will NOT be initialized in advance) 
; should be stored starting at x3F00, with the non-alphabetic count 
; at x3F00, and the count for each letter in x3F01 (A) through x3F1A (Z).
;
; table of register use in this part of the code
;    R0 holds a pointer to the histogram (x3F00)
;    R1 holds a pointer to the current position in the string
;       and as the loop count during histogram initialization
;    R2 holds the current character being counted
;       and is also used to point to the histogram entry
;    R3 holds the additive inverse of ASCII '@' (xFFC0)
;    R4 holds the difference between ASCII '@' and 'Z' (xFFE6)
;    R5 holds the difference between ASCII '@' and '`' (xFFE0)
;    R6 is used as a temporary register
;

	LD R0,HIST_ADDR      	; point R0 to the start of the histogram
	
	; fill the histogram with zeroes 
	AND R6,R6,#0		; put a zero into R6
	LD R1,NUM_BINS		; initialize loop count to 27
	ADD R2,R0,#0		; copy start of histogram into R2

	; loop to fill histogram starts here
HFLOOP	STR R6,R2,#0		; write a zero into histogram
	ADD R2,R2,#1		; point to next histogram entry
	ADD R1,R1,#-1		; decrement loop count
	BRp HFLOOP		; continue until loop count reaches zero

	; initialize R1, R3, R4, and R5 from memory
	LD R3,NEG_AT		; set R3 to additive inverse of ASCII '@'
	LD R4,AT_MIN_Z		; set R4 to difference between ASCII '@' and 'Z'
	LD R5,AT_MIN_BQ		; set R5 to difference between ASCII '@' and '`'
	LD R1,STR_START		; point R1 to start of string

	; the counting loop starts here
COUNTLOOP
	LDR R2,R1,#0		; read the next character from the string
	BRz PRINT_HIST		; found the end of the string

	ADD R2,R2,R3		; subtract '@' from the character
	BRp AT_LEAST_A		; branch if > '@', i.e., >= 'A'
NON_ALPHA
	LDR R6,R0,#0		; load the non-alpha count
	ADD R6,R6,#1		; add one to it
	STR R6,R0,#0		; store the new non-alpha count
	BRnzp GET_NEXT		; branch to end of conditional structure
AT_LEAST_A
	ADD R6,R2,R4		; compare with 'Z'
	BRp MORE_THAN_Z     ; branch if > 'Z'

; note that we no longer need the current character
; so we can reuse R2 for the pointer to the correct
; histogram entry for incrementing
ALPHA	ADD R2,R2,R0		; point to correct histogram entry
	LDR R6,R2,#0		; load the count
	ADD R6,R6,#1		; add one to it
	STR R6,R2,#0		; store the new count
	BRnzp GET_NEXT		; branch to end of conditional structure

; subtracting as below yields the original character minus '`'
MORE_THAN_Z
	ADD R2,R2,R5		; subtract '`' - '@' from the character
	BRnz NON_ALPHA		; if <= '`', i.e., < 'a', go increment non-alpha
	ADD R6,R2,R4		; compare with 'z'
	BRnz ALPHA			; if <= 'z', go increment alpha count
	BRnzp NON_ALPHA		; otherwise, go increment non-alpha

GET_NEXT
	ADD R1,R1,#1		; point to next character in string
	BRnzp COUNTLOOP		; go to start of counting loop



PRINT_HIST

; you will need to insert your code to print the histogram here

; do not forget to write a brief description of the approach/algorithm
; for your implementation, list registers used in this part of the code,
; and provide sufficient comments

; Algorithm for PRINT_HIST:
; Use the Loop to print each line of the goal table, which should be presented 
; in the form of : char + space + amount in hexadecimal + newline.
; To calculate the amount of each bin in hexadecimal, we use the digit shift 
; & bit mask method to make 4 digits in binary to be printed in 1 digit in hexadecimal

; R0 for printing
; R1 contains the char to be printed
; R2 contains the number of rows(bins) to be printed
; R3 contains digit counter to be printed
; R4 contains another digit counter to make make 4 digits(binary) to 1 digit(hexadecimal)
;    and also be used to transfer to ASCII
; R5 contains address of the bin digit to be printed
; R6 is used as a temporary register

	LD	R1,AT
	LD  R2,NUM_BINS
	LD  R5, HIST_ADDR

PRINT_ROW
; First, Print char/non-char 
	ADD	R0,R1,#0
	OUT

; Second, Print space
	LD  R0,SPACE
	OUT

; Third, Print the hexadecimal 4-digit amount
	AND	R3,R3,#0
	ADD R3,R3,#4	; Initializing Big digit counter to be 4
	LDR R6,R5,#0	; Initializing R6 to hold the bit number of each bin stores of the HIST

PRINT_DIGIT
	AND R0,R0,#0
	AND R4,R4,#0	
	ADD R4,R4,#4	; Initializing Small digit counter to be 4 AND R0 to be 0

; Loop four bits to get a dgit
ONE_DIGIT
	ADD R4,R4,#0
	BRz	TRANSFER	; Judge whether get 4 bits

	ADD R0,R0,R0	; Shift digit left, R0 is used to be the digit that to be printed
	ADD R6,R6,#0	
	BRzp CHECK_N_BIT
	ADD R0,R0,#1
CHECK_N_BIT
	ADD R6,R6,R6	; Shift bit left
	ADD R4,R4,#-1
	BRnzp ONE_DIGIT

; Transfer to ASCII mode
TRANSFER			
	ADD R4,R0,#-9
	BRp LARGER_T_NINE
	LD  R4,ZERO
	ADD R0,R0,R4
	OUT
	BRnzp DECRE
LARGER_T_NINE		; When the printed digit is Larger than '9'
	LD	R6,LETTER_A
	ADD R0,R0,R6
	ADD R0,R0,#-10
	OUT

DECRE				
	ADD R3,R3,#-1
	BRp PRINT_DIGIT	; To print the next digit of one number

; Last, Print the newline
	LD	R0,NEW_LINE
	OUT

	ADD R5,R5,#1	; Go to next address
	ADD R1,R1,#1	; Increment R1 for the next char to be printed
	ADD R2,R2,#-1	
	BRz	DONE		; Judge whether 27 bins have been printed
	BRnzp PRINT_ROW
	

DONE	HALT			; done


; the data needed by the program
NUM_BINS	.FILL #27	; 27 loop iterations
NEG_AT		.FILL xFFC0	; the additive inverse of ASCII '@'
AT_MIN_Z	.FILL xFFE6	; the difference between ASCII '@' and 'Z'  "-x001B" #-27
AT_MIN_BQ	.FILL xFFE0	; the difference between ASCII '@' and '`'
HIST_ADDR	.FILL x3F00     ; histogram starting address
STR_START	.FILL x4000	; string starting address
AT			.FILL x0040 ; ASCII '@'
SPACE 		.FILL x0020	; ASCII 'space'
NEW_LINE	.FILL x000A ; ASCII 'newline'
ZERO 		.FILL x0030	; ASCII '0'
LETTER_A	.FILL x0041	; ASCII 'A'

; for testing, you can use the lines below to include the string in this
; program...
; STR_START	.FILL STRING	; string starting address
; STRING		.STRINGZ "AAAAAAAAAABBBBB!!!3932UUUUOOBBBBBBCDJEANDEJD."



	; the directive below tells the assembler that the program is done
	; (so do not write any code below it!)

	.END
