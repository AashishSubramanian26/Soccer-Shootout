*-----------------------------------------------------------
* Title      : Title Screen Soccer Shootout
* Written by : Aashish Subramanian
* Date       : 8/3/2023
* Description: Drawing shapes and text for the title screen until space is pressed
*               After space is pressed, then the player will be able to play the game
*-----------------------------------------------------------
Green           EQU     $001BF05F 
Black           EQU     $00000000
White           EQU     $00FFFFFF

LeftOfSquare    EQU     200
RightOfSquare   EQU     430
TopOfSquare     EQU     180
BottomOfSquare  EQU     260

LeftOfSoccer    EQU     450
RightOfSoccer   EQU     550
TopOfSoccer     EQU     40
BottomOfSoccer  EQU     140

LeftOfPattern1  EQU     480
RightOfPattern1 EQU     500
TopOfPattern1   EQU     60
BottomOfPattern1 EQU    80

LeftOfPattern2  EQU     510
RightOfPattern2 EQU     530
TopOfPattern2   EQU     90
BottomOfPattern2 EQU    110

LeftOfPattern3  EQU     465
RightOfPattern3 EQU     485
TopOfPattern3   EQU     110
BottomOfPattern3 EQU    130

LeftOfDash1     EQU     345
RightOfDash1    EQU     450
TopOfDash1      EQU     80
BottomOfDash1   EQU     90
AdjustLeftDash  EQU     40
AdjustRightDash EQU     25
AdjustTopDash   EQU     30
AdjustBottomDash EQU    30

SetPenColor     EQU     80
SetFillColor    EQU     81
DrawCircle      EQU     88
DrawSquare      EQU     87
PrintText       EQU     95
 
PrintScore      EQU     17   
    
DRAW_TITLE_SCREEN:                  

* Put program code here
    MOVE.l  #SetPenColor, d0
    MOVE.l  #Green, d1
    TRAP    #15

    MOVE.l  #SetFillColor, d0
    TRAP    #15
    
    MOVE.l  #DrawSquare, d0
    MOVE.l  #LeftOfSquare, d1
    MOVE.l  #RightOfSquare, d3
    MOVE.l  #TopOfSquare, d2
    MOVE.l  #BottomOfSquare, d4
    TRAP    #15   

    MOVE.l  #PrintText, d0
    LEA     nameOfGame, a1
    
    MOVE.l  #250, d1
    MOVE.l  #200, d2
    TRAP    #15
    
    LEA     PressPlay, a1
    MOVE.l  #230, d1
    MOVE.l  #220, d2
    TRAP    #15
    
    
    MOVE.l  #SetPenColor, d0
    MOVE.l  #White, d1
    TRAP    #15

    MOVE.l  #SetFillColor, d0
    TRAP    #15
    
    MOVE.l  #DrawCircle, d0       
    MOVE.l  #LeftOfSoccer, d1    
    MOVE.l  #RightOfSoccer, d3   
    MOVE.l  #TopOfSoccer, d2     
    MOVE.l  #BottomOfSoccer, d4  
    TRAP    #15                     
    
    MOVE.l  #DrawSquare, d0
    MOVE.l  #LeftOfDash1, d1    
    MOVE.l  #RightOfDash1, d3   
    MOVE.l  #TopOfDash1, d2     
    MOVE.l  #BottomOfDash1, d4  
    TRAP    #15               
    
    ADD.l   #AdjustLeftDash, d1
    ADD.l   #AdjustRightDash, d3
    SUB.l   #AdjustTopDash, d2
    SUB.l   #AdjustBottomDash, d4
    TRAP    #15
    
    
    
    
    MOVE.l  #SetPenColor, d0
    MOVE.l  #Black, d1
    TRAP    #15

    MOVE.l  #SetFillColor, d0
    TRAP    #15
    
    MOVE.l  #DrawCircle, d0       
    MOVE.l  #LeftOfPattern1, d1    
    MOVE.l  #RightOfPattern1, d3   
    MOVE.l  #TopOfPattern1, d2     
    MOVE.l  #BottomOfPattern1, d4  
    TRAP    #15                     
    
    MOVE.l  #LeftOfPattern2, d1    
    MOVE.l  #RightOfPattern2, d3   
    MOVE.l  #TopOfPattern2, d2     
    MOVE.l  #BottomOfPattern2, d4  
    TRAP    #15         

    MOVE.l  #LeftOfPattern3, d1    
    MOVE.l  #RightOfPattern3, d3   
    MOVE.l  #TopOfPattern3, d2     
    MOVE.l  #BottomOfPattern3, d4  
    TRAP    #15         

    RTS
*--------------------------------
SHOW_RESULTS:
    JSR     CLEAR_SCREEN
    
    MOVE.l  #SetPenColor, d0
    MOVE.l  #White, d1
    TRAP    #15

    MOVE.l  #SetFillColor, d0
    MOVE.l  #Black, d1
    TRAP    #15

    
    
    MOVE.l  #PrintScore, d0
    LEA     scoreString, a1
    MOVE.l  totalScore, d1
    TRAP    #15
    
    JSR     SWAP_BUFFERS
    
    RTS    
    
FIRST_TIME_INTIALIZE_VARIABLES:
    JSR     INITIALIZE_VARIABLES
    MOVE.b  #0, resetFlag
    MOVE.b  #1, titleScreenOn
    MOVE.l  #3, totalLives
    MOVE.l  #0, totalScore
    MOVE.b  #0, gameOverFlag
*    MOVE.l  #0, velocityX
*    MOVE.l  #0, velocityY
    MOVE.b  #0, secondDigitValue
    MOVE.b  #0, firstDigitValue
    MOVE.b  #0, secondDigitFlag
    
    RTS    
    
    
INITIALIZE_VARIABLES:
    MOVE.b  #0, hasCollided 
    MOVE.b  #0, hasKickedBall
    
    
    RTS
    
* Put variables and constants here
gameOverFlag    ds.b    1
resetFlag       ds.b    1
titleScreenOn   ds.b    1
nameOfGame      dc.l    'Soccer Shootout!!', 0
pressPlay       dc.l    'Press Enter to play!!', 0
scoreString     dc.l    'Total Score: ', 0
  








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
