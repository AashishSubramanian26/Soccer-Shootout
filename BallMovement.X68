*-----------------------------------------------------------
* Title      :  Ball Movement
* Written by :  Aashish Subramanian
* Date       :  7/12/2023
* Description:  After getting the player input, we know the correct angle as to where to shoot
*-----------------------------------------------------------
;REMOVE EQUATES LATER WHEN COMBINING FILES, HAVE SINGLE FILE FOR ALL EQUATES
White           EQU     $00FFFFFF
Gray            EQU     $0074747C

Velocity        EQU         3
BallRadius      EQU         25

SetPenColor     EQU         80
SetFillColor    EQU         81
DrawCircle      EQU         88
ReturnTime      EQU         8
SetPenWidth     EQU         93
PenWidthValue   EQU         5
BallWidthValue  EQU         5

Acceleration    EQU         2

PreShifting     EQU         1024    
*----------------------- 
FIND_XY_VELOCITY_COMPONENTS:
    ;We need to find the X and Y components of the velocity 
    
    ;Find Vx -> cos(#) = Vx / V
    CLR.l   d1
    MOVE.l  currentCosAnglePointer, a1      
    MOVE.w  (a1), d1        ;Putting the value of the cos(#) into d1 (this angle is already multiplied by 1024 (2^10)
    MULU    #Velocity, d1
    
AssignVelocity:
    MOVE.l  d1, velocityX
    
    
    ;Find Vy -> sin(#) = Vy / V
    MOVE.l  currentSinAnglePointer, a1
    MOVE.w  (a1), d1
    MULU    #Velocity, d1
    MOVE.l  d1, velocityY
    
    
    RTS
              
*-----------------------     
FIND_DELTA_TIME:    
    MOVE.l  #ReturnTime, d0
    TRAP    #15     ;D1 should have time in hundredths of a second since midnight
    
    MOVE.l  d1, d3  ;Storing the time right now in d3 
    ;DeltaTime = Previous time - currenttime (d1)
    MOVE.l  previousTime, d2
    SUB.l   d2, d1
    
    MOVE.l  d3, previousTime    ;Saving the currentTime as the previousTime
    MOVE.l  d1, deltaTime      
    
    RTS
*-----------------------
FIND_VELOCITY_CHANGE:
    ;EQUATION:  Vf = Vi - acceleration*deltaTime ->(Decleration)
    
    ;First lets do Vx
    MOVE.l  velocityX, d1
    MOVE.l  deltaTime, d2
    MOVE.l  #Acceleration, d3
    MULS.w  d3, d2
    
    SUB.l   d2, d1
    
    MOVE.b  d1, velocityX
    
    ;Next, find Vy
    MOVE.l  velocityY, d1
    MOVE.l  deltaTime, d2
    MOVE.l  #Acceleration, d3
    MULS.w  d3, d2
    
    SUB.l   d2, d1
    
    MOVE.b  d1, velocityY
    
    RTS  

*-----------------------
CALCULATE_BALL_POSITION: 
    ;Displacement = Velocity*deltaTime
    ;Xi = Right of Ball = D3
    MOVE.l  rightOfBallX, d3      ;Gets updated in DrawBall
    MOVE.l  leftOfBallX, d5
     
    ;Yi = Bottom of ball = D4
    MOVE.l  bottomOfBallY, d4
    MOVE.l  topOfBallY, d6
    
    MOVE.l  deltaTime, d2
   
    ;Let's find the DeltaXPosition
    ;DisplacementX = Vx * deltaTime
    
    ;Calculate for Vx* deltaTime
    MOVE.l  velocityX, d1
    MULU    d2, d1    ;DISPLACEMENT
    
    
    MOVE.l  howManyDegreesFrom90, d0
    BLT     LeftDirection
    BRA     RightDirection
    
LeftDirection:
    SUB.l   d1, d3
    MOVE.l  d3, rightOfBallX
    SUB.l   d1, d5
    MOVE.l  d5, leftOfBallX
    BRA     FindDisplacementY

RightDirection:    
    ADD.l   d1, d3
    MOVE.l  d3, rightOfBallX
    ADD.l   d1, d5
    MOVE.l  d5, leftOfBallX
    
FindDisplacementY:     
    ;Let's find the DeltaYPosition
    ;DisplacementY = Vx * deltaTime
    
    ;Calculate for Vx* deltaTime
    MOVE.l  velocityY, d1
    MULU    d2, d1  
     
    SUB.l   d1, d4
    MOVE.l  d4, bottomOfBallY
    SUB.l   d1, d6
    MOVE.l  d6, topOfBallY 
     
     
    RTS
*-----------------------
SETUP_INITIAL_BALL:
    MOVE.l  #LeftBallX, d5
    MULU.w  #PreShifting, d5
    MOVE.l  d5, leftOfBallX
    
    MOVE.l  #RightBallX, d5
    MULU.w  #PreShifting, d5
    MOVE.l  d5, rightOfBallX
    
    MOVE.l  #UpperBallY, d5
    MULU.w  #PreShifting, d5
    MOVE.l  d5, topOfBallY
    
    MOVE.l  #LowerBallY, d5
    MULU.w  #PreShifting, d5
    MOVE.l  d5, bottomOfBallY
    
    RTS
*----------------------- 
DRAW_BALL:
    MOVE.w  #SetPenColor, d0
    MOVE.l  #White, d1
    TRAP    #15
    MOVE.w  #SetFillColor, d0
    TRAP    #15

    MOVE.w  #SetPenWidth, d0
    MOVE.b  #BallWidthValue, d1
    TRAP    #15
  
    MOVE.l  leftOfBallX, d1
    LSR.l   #8, d1
    LSR.l   #2, d1
    
    MOVE.l  rightOfBallX, d3
    LSR.l   #8, d3
    LSR.l   #2, d3
    
    MOVE.l  topOfBallY, d2
    LSR.l   #8, d2
    LSR.l   #2, d2
    
    MOVE.l  bottomOfBallY, d4 
    LSR.l   #8, d4
    LSR.l   #2, d4    
    
    MOVE.w  #DrawCircle, d0
    TRAP    #15    

    MOVE.b  #0, ballIsKickedInitially
    
    RTS

  
* Put variables and constants here
velocityX                   ds.l    1
velocityY                   ds.l    1
previousTime                dc.l    0
deltaTime                   ds.l    1
deltaXPosition              ds.l    1
deltaYPosition              ds.l    1
leftOfBallX                 ds.l    1
rightOfBallX                ds.l    1
topOfBallY                  ds.l    1
bottomOfBallY               ds.l    1
changeInXPositionPerFrame   ds.l    1
changeInYPositionPerFrame   ds.l    1




















*~Font name~Courier New~
*~Font size~8~
*~Tab type~1~
*~Tab size~4~
