*-----------------------------------------------------------
* Title      : Defender Movement
* Written by : Aashish Subramanian
* Date       : 7/17/2023
* Description: The defender needs to move left and right trying to protect the goal
*               This code will get a random value to give the defender a random speed each round
*-----------------------------------------------------------
    
Blue                    equ     $00FFB90B    

MaxValueForSpeedOne     EQU     144
MaxValueForSpeedTwo     EQU     226

VelocitySpeedOne        EQU     3
VelocitySpeedTwo        EQU     5
VelocitySpeedThree      EQU     8

LeftOfDefender          EQU     310     ;UPDATING
RightOfDefender         EQU     340     ;UPDATING
TopOfDefender           EQU     140
BottomOfDefender        EQU     170

SetPenColor             EQU     80
SetFillColor            EQU     81
DrawCircle              EQU     88

LeftOfGoalX             EQU     130
RightOfGoalX            EQU     520
TopOfGoalY              EQU     0
BottomOfGoalY           EQU     100
GoalWidthValue          EQU     5
DrawGoal                EQU     90


*-----------------------
SET_RANDOM_SPEED:
    MOVE.b  randomValue, d0
    
    CMPI.w  #MaxValueForSpeedOne, d0        ;If our randomValue is smaller than the maxvalue, then set velocity speed to lowest
    BLT     SetSpeedOne
    
    CMPI.w  #MaxValueForSpeedTwo, d0
    BLT     SetSpeedTwo
        
    MOVE.l  #VelocitySpeedThree, defenderVelocity
        
    BNE     RETURN_SPEED
    
SetSpeedOne:
    MOVE.l  #VelocitySpeedOne, defenderVelocity

    BNE     RETURN_SPEED
    
SetSpeedTwo:
    MOVE.l  #VelocitySpeedTwo, defenderVelocity

RETURN_SPEED:
    RTS    
*-----------------------
INITIALIZE_DEFENDER_LOCATION:
    MOVE.l  #LeftOfDefender, leftOfDefenderX
   
    MOVE.l  #RightOfDefender, rightOfDefenderX
    
    MOVE.l  #TopOfDefender, topOfDefenderY
      
    MOVE.l  #BottomOfDefender, bottomOfDefenderY
     
    MOVE.b  #1, moveLeftFlag
  
    RTS
*-----------------------
CALCULATE_DEFENDER_POSITION:                
    CLR.l   d6
    MOVE.l  leftOfDefenderX, d1
    MOVE.l  rightOfDefenderX, d3
    

    MOVE.l  defenderVelocity, d7
    MOVE.l  deltaTime, d2
    
    MULU.w  d7, d2          ;d2 has the displacement now
    
    MOVE.b  moveLeftFlag, d6
    ;Need to check whether the flag needs to be 1 or 0 for the MoveLeftFlag 
    ;If MoveLeftFlag = 1, we need to move left, if 0, then move right 
    ;MoveLeftFlag = 1 when our d3/ right edge of the defender is greater than the right most edge of the goal
    ;When that happens, defender needs to turn around
    ;MoveLeftFlag = 0 when our right most edge is less than the left most edge of the goal, if so go towards the right
    BNE     CHECK_LEFT_EDGE     'If we are already one, then skip setting 

                                ;If it is 0, then we are currently moving towards the right direction, but need to make sure
                                ;we dont go beyond the right edge of goal post
    CMPI.l  #RightOfGoalX, d3
    BGT     SET_LEFT_FLAG_HIGH
    
    BRA     FINISH_SETTING_FLAG   
        
CHECK_LEFT_EDGE:        ;Since we are moving in the left direction, we need to see if we have reached the left most edge
    CMPI.l  #LeftOfGoalX, d3
    BLT     SET_LEFT_FLAG_LOW            
        
SET_LEFT_FLAG_HIGH:
    MOVE.b  #1, moveLeftFlag
    BNE     FINISH_SETTING_FLAG
        
SET_LEFT_FLAG_LOW:
    MOVE.b  #0, moveLeftFlag
    
FINISH_SETTING_FLAG:
    MOVE.b  moveLeftFlag, d6
    
    BNE     MOVE_LEFT_DIRECTION     ;If flag is 1 then move left, else move right
    
    ADD.l   d2, d3
    MOVE.l  d3, rightOfDefenderX
    ADD.l   d2, d1
    MOVE.l  d1, leftOfDefenderX
    
    MOVE.b  #0, moveLeftFlag
   
    BRA     FINISH_MOVING_DEFENDER
    
MOVE_LEFT_DIRECTION:
    SUB.l   d2, d3
    MOVE.l  d3, rightOfDefenderX
    
    SUB.l   d2, d1
    MOVE.l  d1, leftOfDefenderX
    
    MOVE.b  #1, moveLeftFlag
    
    
FINISH_MOVING_DEFENDER:    
    RTS
*-----------------------  
DRAW_DEFENDER:
    MOVE.l  #SetPenColor, d0
    MOVE.l  #Blue, d1
    TRAP    #15
    MOVE.w  #SetFillColor, d0
    TRAP    #15
    
    MOVE.l  leftOfDefenderX, d1
    MOVE.l  rightOfDefenderX, d3
    MOVE.l  topOfDefenderY, d2
    MOVE.l  bottomOfDefenderY, d4
    
DEFENDER_ON_SCREEN    
    MOVE.l  #DrawCircle, d0
    TRAP    #15

    RTS 
*-----------------------  
DRAW_GOAL:
    MOVE.w  #SetPenColor, d0
    MOVE.l  #Gray, d1
    TRAP    #15
    MOVE.w  #SetFillColor, d0
    TRAP    #15

    MOVE.w  #SetPenWidth, d0
    MOVE.b  #GoalWidthValue, d1
    TRAP    #15

    MOVE.l  #LeftOfGoalX, d1
    MOVE.l  #RightOfGoalX, d3
    MOVE.l  #TopOfGoalY, d2
    MOVE.l  #BottomOfGoalY, d4
    
    MOVE.l  #DrawGoal, d0
    TRAP    #15

    RTS

moveLeftFlag        ds.b    1  
randomValue         ds.b    1  
defenderVelocity    ds.l    1     
leftOfDefenderX     ds.l    1      
rightOfDefenderX    ds.l    1
topOfDefenderY      ds.l    1    
bottomOfDefenderY   ds.l    1    












*~Font name~Courier New~
*~Font size~8~
*~Tab type~1~
*~Tab size~4~
