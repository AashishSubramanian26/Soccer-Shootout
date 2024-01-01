*-----------------------------------------------------------
* Title      :  7-Segment LED Display
* Written by :  Aashish Subramanian 
* Date       :  8/6/2023
* Description:  This program will be updating the lives and the score counter on the screen
*-----------------------------------------------------------
SaveD1         REG     D1

White           EQU     $00FFFFFF    
SetPenColor     EQU     80
SetFillColor    EQU     81
SetPenWidth     EQU     93
DrawLine        EQU     84    
PenWidth        EQU     5

;LOCAL VARIABLES
Y2              EQU     8
X2              EQU     12
Y1              EQU     16
X1              EQU     20

ByteCounter         EQU     7
UpdateToNextLetter  EQU     16
MoveStackPointer    EQU     16

;TABLE X AND Y POINTS
LeftOfLivesX        EQU     540
RightOfLivesX       EQU     600
TopOfSegmentY       EQU     30
MiddleOfSegmentY    EQU     70
BottomOfSegmentY    EQU     110

LeftOfFirstDigitX   EQU     83
RightOfFirstDigitX  EQU     120

LeftOfSecondDigitX  EQU     25
RightOfSecondDigitX EQU     65



UPDATE_SCORE_DIGITS:
    MOVE.b  secondDigitFlag, d0
    BNE     LEAVE_FIRST_DIGIT
    
    ;CHECK IF SCORE is 0, IF SO THEN SKIP
    MOVE.l  totalScore, d0
    BEQ     LEAVE_FIRST_DIGIT
    
    ;We are dividing the score by 10 to find what the remainder is. The remainder is what our score is for the first digit
    ;When the remainder 0, that means we reached a new tens place therefore, have to increase our second digit by 1  
    DIVU.w  #10, d0
    LSR.l   #8, d0
    LSR.l   #8, d0
    
    CMP.b   #0, d0              ;If the remainder is 0, then we update the second digit  
    BEQ     INCREASE_SECOND_DIGIT
                                ;If the remainder is not 0, we just want to update the ones place
    MOVE.b  d0, firstDigitValue
    BRA     LEAVE_FIRST_DIGIT
INCREASE_SECOND_DIGIT:
    MOVE.b  d0, firstDigitValue
    ADD.b   #1, secondDigitValue
    MOVE.b  #1, secondDigitFlag
LEAVE_FIRST_DIGIT:  
    RTS

*--------------------------------------    
DRAW_SEGMENT:   ;General function that draws the lettered segemnts that are on
    MOVEM.l SaveD1, -(sp)

    MOVE.l  #SetPenColor, d0
    MOVE.l  #White, d1
    TRAP    #15
    MOVE.l  #SetFillColor, d0
    TRAP    #15
    
    MOVE.l  #SetPenWidth, d0
    MOVE.l  #PenWidth, d1
    TRAP    #15
    
    MOVE.l  #DrawLine, d0
    MOVE.l  X1(sp), d1          ;Passing in the begin X,Y points and end X,Y points for drawing a line
    MOVE.l  Y1(sp), d2
    MOVE.l  X2(sp), d3
    MOVE.l  Y2(sp), d4
    
    TRAP    #15
    
    MOVEM.l (sp)+, SaveD1
    
    RTS

*-----------------------------------------
BIT_CHECK_LOOP:     
    BTST.l  #$0, d1     ;We are checking if the first bit is a 0 or a 1 for the number, if 1, we need to print that letter
    BNE     PASS_SEGMENT_PARAMETERS   
                        ;If the number is 0, we want to skip to the next letter position
    ADD.l   #UpdateToNextLetter, a1
NEXT_LETTER_CHECK:
    LSR.b   #1, d1      ;Moving one bit down to check the next least significant bit
    
    SUBI.l  #1, d7      ;Decreasing the counter because we have 7 bits/segments we can potentially print out
    BEQ     FINISH_PRINT      ;If 0, then no longer want to check bit values, unless keep going
    BRA     BIT_CHECK_LOOP

PASS_SEGMENT_PARAMETERS:
    MOVE.l  (a1)+, -(sp)    ;If we are at a letter segment we want to print, we want to pass the starting(X,Y) and ending (X,Y) points to draw the line and pass into parameter
    MOVE.l  (a1)+, -(sp)
    MOVE.l  (a1)+, -(sp)
    MOVE.l  (a1)+, -(sp)
    JSR     DRAW_SEGMENT 

    ADD.l   #MoveStackPointer, sp
    BRA     NEXT_LETTER_CHECK

FINISH_PRINT:
    RTS
*-----------------------------------------
PRINT_SCORE:
    CLR.l   d1
    CLR.l   d2
    CLR.l   d6
    
    LEA     DrawScoresFirstSegment, a1
    LEA     DrawScoresSecondSegment, a2

    MOVE.l  #ByteCounter, d7
                
    LEA     SegmentTable, a0        ;Takes in the value we determed from FIND_FIRST_DIGIT in order to print out the correct digit in the ones and tens place
    MOVE.b  firstDigitValue, d6
    ADD.l   d6, a0              ;The value that is for our ones place updates our segment table so it knows which number needs to be printed
    MOVE.b  (a0), d1
        
    ;We will be printing out the correct letter segments that correspond to that number we want     
    JSR     BIT_CHECK_LOOP
    
    ;Passing the correct parameters to do it again for the tens place
    LEA     SegmentTable, a0
    MOVE.l  #ByteCounter, d7
    MOVE.b  secondDigitValue, d6        ;Same idea for the firstDigitValue goes for the secondDigit
    ADD.l   d6, a0
    MOVE.b  (a0), d1
    MOVE.l  a2, a1
    
    JSR     BIT_CHECK_LOOP
    
    RTS
  *--------------------------------------------  
PRINT_LIVES:                  
    MOVE.l  #ByteCounter, d7
    MOVE.l  totalLives, d0
    LEA     SegmentTable, a0
    ADD.l   d0, a0      ;address of a0 will hold the number we want from d0
    MOVE.b  (a0), d1
    LEA     DrawLivesSegment, a1
    
    JSR     BIT_CHECK_LOOP
    
    RTS
*--------------------------------------------

secondDigitFlag     ds.l    1
firstDigitValue     ds.b    1
secondDigitValue    ds.b    1
SegmentTable:  
    dc.b    $7E, $30, $6D, $79, $33, $5B, $5F, $70, $7F, $7B
    *       0,   1,    2,  3,   4,   5,    6,   7,   8,   9

DrawLivesSegment:    
    ;StartX, StartY, EndX, EndY
    dc.l    LeftOfLivesX, MiddleOfSegmentY, RightOfLivesX, MiddleOfSegmentY         ;G
    dc.l    LeftOfLivesX, TopOfSegmentY, LeftOfLivesX, MiddleOfSegmentY             ;F
    dc.l    LeftOfLivesX, MiddleOfSegmentY, LeftOfLivesX, BottomOfSegmentY          ;E
    dc.l    LeftOfLivesX, BottomOfSegmentY, RightOfLivesX, BottomOfSegmentY         ;D
    dc.l    RightOfLivesX, MiddleOfSegmentY, RightOfLivesX, BottomOfSegmentY        ;C
    dc.l    RightOfLivesX, TopOfSegmentY, RightOfLivesX, MiddleOfSegmentY           ;B
    dc.l    LeftOfLivesX, TopOfSegmentY, RightOfLivesX, TopOfSegmentY               ;A
        
DrawScoresFirstSegment:
    ;StartX, StartY, EndX, EndY
    dc.l    LeftOfFirstDigitX, MiddleOfSegmentY, RightOfFirstDigitX, MiddleOfSegmentY       ;G
    dc.l    LeftOfFirstDigitX, TopOfSegmentY, LeftOfFirstDigitX, MiddleOfSegmentY           ;F
    dc.l    LeftOfFirstDigitX, MiddleOfSegmentY, LeftOfFirstDigitX, BottomOfSegmentY        ;E
    dc.l    LeftOfFirstDigitX, BottomOfSegmentY, RightOfFirstDigitX, BottomOfSegmentY       ;D
    dc.l    RightOfFirstDigitX, MiddleOfSegmentY, RightOfFirstDigitX, BottomOfSegmentY      ;C
    dc.l    RightOfFirstDigitX, TopOfSegmentY, RightOfFirstDigitX, MiddleOfSegmentY         ;B
    dc.l    LeftOfFirstDigitX, TopOfSegmentY, RightOfFirstDigitX, TopOfSegmentY             ;A

DrawScoresSecondSegment
;StartX, StartY, EndX, EndY
    dc.l    LeftOfSecondDigitX,MiddleOfSegmentY,RightOfSecondDigitX,MiddleOfSegmentY        ;G
    dc.l    LeftOfSecondDigitX,TopOfSegmentY,LeftOfSecondDigitX,MiddleOfSegmentY            ;F
    dc.l    LeftOfSecondDigitX,MiddleOfSegmentY,LeftOfSecondDigitX,BottomOfSegmentY         ;E
    dc.l    LeftOfSecondDigitX,BottomOfSegmentY,RightOfSecondDigitX,BottomOfSegmentY        ;D
    dc.l    RightOfSecondDigitX,MiddleOfSegmentY,RightOfSecondDigitX,BottomOfSegmentY       ;C
    dc.l    RightOfSecondDigitX,TopOfSegmentY,RightOfSecondDigitX,MiddleOfSegmentY          ;B
    dc.l    LeftOfSecondDigitX,TopOfSegmentY,RightOfSecondDigitX,TopOfSegmentY              ;A












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
