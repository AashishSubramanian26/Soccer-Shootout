*-----------------------------------------------------------
* Title      : CollisionDetection
* Written by : Aashish Subramanian
* Date       : 8/2/2023
* Description: This is the code that will check if our ball has collided with something
*               If the ball hits the bounds of the field, the defender, or the front left 
*               and right edges of the fence, they will lose a life. 
*               However, if the ball goes past the defender and inside of the net, they will get a point
*               Flags will be set whether or not the ball has collided with something or not
*-----------------------------------------------------------
;Local Variables - Stack
BottomOfY2          EQU     4
TopOfY2             EQU     8
RightOfX2           EQU     12
LeftOfX2            EQU     16
BottomOfY1          EQU     20
TopOfY1             EQU     24
RightOfX1           EQU     28
LeftOfX1            EQU     32

LeftOfField         EQU         0<<10
RightOfField        EQU         640<<10
Diameter            EQU         30      ;The diameter of the ball and defender

UpdateStackPointer    EQU         32  


CHECK_FIELD_COLLISIONS:   ;If the ball has collided with anything then set
                    ;the HasCollided flag to be high, so when rendering, we know we hit something
    ;Lets first check if the ball has collided with the left and right edge of field
    MOVE.l  rightOfBallX, d0
    CMPI.l  #LeftOfField, d0
    BLT     SET_FIELD_COLLIDED_FLAG
    
    MOVE.l  leftOfBallX, d0
    CMPI.l  #RightOfField, d0
    BGT     SET_FIELD_COLLIDED_FLAG
   

    MOVE.b  #0, hasCollided
    BRA     FINISH__FIELD_COLLIDE_CHECKS
    
SET_FIELD_COLLIDED_FLAG:
    MOVE.b  #1, hasCollided
    SUBI.l  #1, totalLives
    MOVE.b  #0, resetFlag
    
FINISH__FIELD_COLLIDE_CHECKS:    
    RTS
*--------------------------------
CHECK_DEFENDER_COLLISIONS:
    ;We first need to pass in the parameters of all ball and defender values into the general collison subroutine
    MOVE.l  leftOfBallX, d1
    LSR.l   #8, d1
    LSR.l   #2, d1
    MOVE.l  d1, -(sp)               ;LeftOfBallX = LeftOfX1
    
    MOVE.l  rightOfBallX, d1
    LSR.l   #8, d1
    LSR.l   #2, d1
    MOVE.l  d1, -(sp)               ;RightOfBallX = RightOfX1
    
    MOVE.l  topOfBallY, d1
    LSR.l   #8, d1
    LSR.l   #2, d1
    MOVE.l  d1, -(sp)               ;TopOfBallY = TopOfY1
    
    MOVE.l  bottomOfBallY, d1
    LSR.l   #8, d1
    LSR.l   #2, d1
    MOVE.l  d1, -(sp)               ;BottomOfBallY  = BottomOfY1
    
    MOVE.l  leftOfDefenderX, -(sp)  ;LeftOfDefenderX = LeftOfX2
    MOVE.l  rightOfDefenderX, -(sp) ;RightOfDefenderX = RightOfX2
    MOVE.l  topOfDefenderY, -(sp)   ;TopOfDefenderY = TopOfY2
    MOVE.l  bottomOfDefenderY, -(sp) ;BottomOfDefenderY = BottomOfY2 

    JSR     COLLISION_TEST
    
    ADD.l   #UpdateStackPointer, sp
    
    MOVE.b  hasCollided, d0
    BEQ     SKIP_GOAL_CHECK

    SUBI.l  #1, totalLives

       
SKIP_DEFENDER_CHECK:
    RTS
*--------------------------------
CHECK_GOAL_COLLISIONS:
    ;We first need to pass in the parameters of all ball and the goal values into the general collision subroutine 
    MOVE.l  leftOfBallX, d1
    LSR.l   #8, d1
    LSR.l   #2, d1
    MOVE.l  d1, -(sp)               ;LeftOfBallX = LeftOfX1
    
    MOVE.l  rightOfBallX, d1
    LSR.l   #8, d1
    LSR.l   #2, d1
    MOVE.l  d1, -(sp)               ;RightOfBallX = RightOfX1
    
    MOVE.l  topOfBallY, d1
    LSR.l   #8, d1
    LSR.l   #2, d1
    MOVE.l  d1, -(sp)               ;TopOfBallY = TopOfY1
    
    MOVE.l  bottomOfBallY, d1
    LSR.l   #8, d1
    LSR.l   #2, d1
    MOVE.l  d1, -(sp)               ;BottomOfBallY  = BottomOfY1

    MOVE.l  #LeftOfGoalX, -(sp)
    MOVE.l  #RightOfGoalX, -(sp)
    MOVE.l  #TopOfGoalY, -(sp)
    MOVE.l  #BottomOfGoalY, -(sp)
    
    
    JSR     COLLISION_TEST
    
    ADD.l   #UpdateStackPointer, sp
    
    MOVE.b  hasCollided, d0
    BEQ     SKIP_GOAL_CHECK

    ADD.l   #1, totalScore
    MOVE.b  #0, secondDigitFlag

SKIP_GOAL_CHECK:    
    RTS
*--------------------------------
COLLISION_TEST:
    ;Check if LeftOfX1 <= RightOfX2
    MOVE.l  RightOfX2(sp), d1
    CMP.l   LeftOfX1(sp), d1
    BLT     FAILED_TEST     ;It passes through if that statement is true
    
    ;Check if RightOfX1 >= LeftOfX2
    MOVE.l  LeftOfX2(sp), d1
    CMP.l   RightOfX1(sp), d1
    BGT     FAILED_TEST
    
    ;Check if BottomOfY1 >= TopOfY2
    MOVE.l  TopOfY2(sp), d1
    CMP.l   BottomOfY1(sp), d1
    BGT     FAILED_TEST
    
    ;Check if TopOfY1 <= BottomOfY2
    MOVE.l  BottomOfY2(sp), d1
    CMP.l   TopOfY1(sp), d1
    BLT     FAILED_TEST
    
    ;If all of these passed then we have collided with the object
    MOVE.b  #1, hasCollided
    MOVE.b  #0, resetFlag
    
    BRA     LEAVE_TEST
    
    
FAILED_TEST:
    MOVE.b  #0, hasCollided

LEAVE_TEST:
    RTS

* Put variables and constants here
hasCollided     dc.b    1
totalScore      dc.l    1
totalLives      dc.l    1

    









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
