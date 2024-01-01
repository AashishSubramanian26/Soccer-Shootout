*-----------------------------------------------------------
* Title      :  Ball Input 
* Written by :  Aashish Subramanian 
* Date       :  7/4/2023
* Description:  This code will draw a ball and a line on the screen. You can move the lin left and right
            ;   when you press A and D from the kayboard. After you get the desired location, press space to shoot
            ;   the ball       
*-----------------------------------------------------------
White           EQU     $00FFFFFF  
Red             EQU     $000000FF
SaveRegisters   REG     D5/D6

SetPenColor     EQU     80
SetFillColor    EQU     81
DrawCircle      EQU     88
DrawLine        EQU     84
SetPenWidth     EQU     93
PenWidthValue   EQU     5
KeyInputTask    EQU     19
ClearScreenTask EQU     11
;BallWidthValue  EQU     1

KeycodeA        EQU     'A'
KeycodeD        EQU     'D'
KeycodeSpace    EQU     ' '     ;KICK
KeycodeEnter    EQU     13 ;CHANGE LATER

LeftBallX       EQU     310
RightBallX      EQU     340
UpperBallY      EQU     430
LowerBallY      EQU     460

PenBottomX      EQU     325<<10
PenBottomY      EQU     428<<10
PenTopX         EQU     325
PenTopY         EQU     348
Radius          EQU     80

MemoryPointer   EQU     2

MoveTo90Degrees EQU     180
RightLimit      EQU     89
LeftLimit       EQU     $FFA7

DoubleBufferTrap EQU    92
DoubleBufferMode EQU    17
RepaintScreen   EQU     94

*----------------------------------------
SET_DOUBLE_BUFFER:
    MOVE.l  #DoubleBufferTrap, d0
    MOVE.l  #DoubleBufferMode, d1
    TRAP    #15
    
    RTS

SWAP_BUFFERS:
    MOVE.l  #RepaintScreen, d0
    TRAP    #15
    
    RTS
    
  
GET_STARTING_ANGLE:
    LEA     CosTable, a2    ;Our starting angle is at 0, we want it to be at 90 degrees - pointing upward        
    ADD.l   #MoveTo90Degrees, a2        ;Getting us to cos(90)
    MOVE.l  a2, currentCosAnglePointer         
    
    LEA     SinTable, a2
    ADD.l   #MoveTo90Degrees, a2        ;Getting us to sin(90)
    MOVE.l  a2, currentSinAnglePointer
    
    MOVE.l  #0, howManyDegreesFrom90
    MOVE.b  #0, hasKickedBall
    MOVE.b  #1, noInputsFlag
    
    RTS

UPDATE_ANGLE:
    MOVE.b  noInputsFlag, d0            ;If we didn't press anything, the angle should not be moving
    BNE     FINISHED_ANGLE_UPDATE



    ;Check if we have moved left or right
    MOVE.b  haveHadNoDInput, d1
    BNE     MovedLeft       ;If our D flag is 0, that means we want to move right    
                            ;If this isn't true, then A must have been pressed 
        
    
    
    ;Moving Right
    ;CHECK RIGHT LIMIT HERE
    MOVE.l  howManyDegreesFrom90, d1
    CMP.l   #RightLimit, d1     ;We can only be move 90 degrees, we need to be stuck if we want to move more
    BGT     FINISHED_ANGLE_UPDATE
                       
    SUB.l   #MemoryPointer, currentCosAnglePointer
    SUB.l   #MemoryPointer, currentSinAnglePointer
    ADDI.l  #1, howManyDegreesFrom90
    
    BRA     FINISHED_ANGLE_UPDATE
MovedLeft:
    ;CHECK LEFT LIMIT HERE
    MOVE.l  howManyDegreesFrom90, d1
    CMP.W   #LeftLimit, d1     ;We can only be move 90 degrees, we need to be stuck if we want to move more
    BLT     FINISHED_ANGLE_UPDATE

    
    ADD.l   #MemoryPointer, currentCosAnglePointer
    ADD.l   #MemoryPointer, currentSinAnglePointer
    SUB.l   #1, howManyDegreesFrom90   
    
FINISHED_ANGLE_UPDATE: 
    RTS    
*----------------------------------------    
DRAW_NEW_LINE:
    JSR CONFIGURE_LINE    

    MOVE.w  #DrawLine, d0
    MOVE.l  #PenBottomX, d1
    LSR.l   #8, d1
    LSR.l   #2, d1
        
    MOVE.l  #PenBottomY, d2
    LSR.l   #8, d2
    LSR.l   #2, d2
    
    
    MOVE.l  xEndPoint, d3
    LSR.l   #8, d3
    LSR.l   #2, d3
    MOVE.l  yEndPoint, d4
    LSR.l   #8, d4
    LSR.l   #2, d4
    
    TRAP    #15
    
    RTS
              
*----------------------------------------    
FIND_XY_POINT:
    ;Find X      
    MOVE.l  currentCosAnglePointer, a2
    MOVE.w  (a2), d1            ;d1 gets the cos(angle) * 2^10
    MULU.w  #Radius, d1
                                ;(cos(angle) * 2^10) * radius) / 2^10
    
    ;If our angle is greater than 90 degrees, we have to subtract StartingX - CalculatedPoint = XEndPoint
    MOVE.l  howManyDegreesFrom90, d2
    CMPI.l  #0, d2          ;Checking if our variable checker is negative
    BLT     angleGreaterThan90

    ADD.l   #PenBottomX, d1     
    MOVE.l  d1, xEndPoint       ;We have gotten the X coord of the end of line 
    CLR.l   d1
    BRA     FindY

AngleGreaterThan90:
    MOVE.l  #PenBottomX, d3     ;Since we are beyond 90s, we have to do XEndPoint = StartingX - CalculatedXPoint
    SUB.l   d1, d3
    MOVE.l  d3, xEndPoint    
     
FindY:    
    ;Find Y 
    MOVE.l  currentSinAnglePointer, a2
    MOVE.w  (a2), d1            ;d1 = sin(angle) * 2^10
    MULU.w  #Radius, d1         ;(sin(angle) * 2^10) * radius)
    MOVE.l  #PenBottomY, d2     
    SUB.l   d1, d2             
    MOVE.l  d2, yEndPoint       ;This gets the correct Y coord for the end of line

    RTS
    
*-----------------------------------------   
CONFIGURE_LINE:
    MOVE.w  #SetPenColor, d0
    MOVE.l  #White, d1
    TRAP    #15
    MOVE.w  #SetFillColor, d0
    TRAP    #15
    MOVE.w  #SetPenWidth, d0
    MOVE.b  #PenWidthValue, d1
    TRAP    #15
    
    RTS
*---------------------------------------- 
DRAW_ATTACKER:
    MOVE.w  #SetPenColor, d0
    MOVE.l  #Red, d1
    TRAP    #15
    MOVE.w  #SetFillColor, d0
    TRAP    #15
    
    MOVE.w  #SetPenWidth, d0
    MOVE.b  #BallWidthValue, d1
    TRAP    #15

    
    MOVE.w  #DrawCircle, d0
    MOVE.w  #LeftBallX, d1
    MOVE.w  #RightBallX, d3
    MOVE.w  #UpperBallY, d2
    MOVE.w  #LowerBallY, d4

    TRAP    #15    
    
    RTS
*---------------------------------------- 
DRAW_INITIAL_LINE:
    JSR CONFIGURE_LINE    
    
    MOVE.w  #DrawLine, d0
    MOVE.l  #PenBottomX, d1
    LSR.l   #8, d1
    LSR.l   #2, d1
    
    MOVE.l  #PenBottomY, d2
    LSR.l   #8, d2
    LSR.l   #2, d2
    
    MOVE.w  #PenTopX, d3
    MOVE.w  #PenTopY, d4
    TRAP    #15

    MOVE.l  d3, d5      ;Store the Top X, Y cords stored in d5 and d6
    MOVE.l  d4, d6
 
       
    MOVE.b  #1, resetFlag
    
    RTS
*---------------------------------------- 
CLEAR_SCREEN:
    CLR.l   d1
    CLR.l   d0
    MOVE.l  #$00000000, a1
    MOVE.w  #$FF00, d1
    MOVE.w  #ClearScreenTask, d0
    TRAP    #15
    CLR.w   d1
    
    RTS  
*-----------------------        
HANDLE_INPUT:
    MOVE.b  titleScreenOn, d0
    BNE     CHECK_INPUT
    
    MOVE.b  hasKickedBall, d0
    BNE     EXIT_INPUT

CHECK_INPUT:
    MOVE.b  #KeyInputTask, d0
    MOVE.l  #KeycodeEnter<<24+KeycodeSpace<<16+KeycodeA<<8+KeycodeD, d1
    TRAP    #15
    
    MOVE.l  d1, d7
    MOVE.l  #$000000FF, d3
    AND.l   d7, d3
    BEQ     SkipD
    
    ;Pressing D - Right             ;If pressing right, Bar needs to move
    MOVE.b  haveHadNoDInput, d0
    BEQ     HAVE_NO_INPUTS
    MOVE.b  #0, haveHadNoDInput
    MOVE.b  #0, noInputsFlag
    
    BEQ     EXIT_INPUT
        
             
SkipD:

    MOVE.b  #1, haveHadNoDInput
    
    LSR.l   #8, d7
    MOVE.l  #$000000FF, d3
    AND.l   d7, d3
    BEQ     SkipA
    
    ;Pressing A
    MOVE.b  haveHadNoAInput, d0
    BEQ     HAVE_NO_INPUTS
    MOVE.b  #0, haveHadNoAInput
    MOVE.b  #0, noInputsFlag 
     
    BEQ     EXIT_INPUT
       
 
SkipA:
    MOVE.b  #1, haveHadNoAInput
    LSR.l   #8, d7
    MOVE.l  #$000000FF, d3
    AND.l   d7, d3
        
    BEQ     SKIP_SPACE
    
    ;Pressing Space
    ;Get a soccer ball to get kicked   
    MOVE.b  #1, hasKickedBall
    MOVE.b  #1, ballIsKickedInitially
    MOVE.b  #0, noInputsFlag
      
 
    BEQ     EXIT_INPUT

SKIP_SPACE:
    LSR.l   #8, d7
    MOVE.l  #$000000FF, d3
    AND.l   d7, d3
        
    BEQ     HAVE_NO_INPUTS
 
 
    ;Pressing Enter
    ;Will start the game so the loading screen will disspear
    MOVE.b  #1, noInputsFlag
    MOVE.b  #0, titleScreenOn
        
    BEQ     EXIT_INPUT
    
HAVE_NO_INPUTS:
    MOVE.b  #1, noInputsFlag        ;In case we don't press anything new, we want to make our program know not to update/render anything new also
   
EXIT_INPUT:
    RTS
    

SIMHALT             ; halt simulator

* Put variables and constants here
noInputsFlag                ds.b    1
haveHadNoDInput             ds.b    1
haveHadNoAInput             ds.b    1
hasKickedBall               ds.b    1 
ballIsKickedInitially       ds.b    1          
currentCosAnglePointer      ds.l    1
currentSinAnglePointer      ds.l    1
xEndPoint                   ds.l    1
yEndPoint                   ds.l    1            
howManyDegreesFrom90        ds.l    1


;ANGLE TABLE
CosTable:       ;Starting at cos(0) until cos(90) -> times the value by 2^10 (into hex)
        dc.w    $400,$400,$3FF,$3FF,$3FE,$3FC,$3FA,$3F8,$3F6,$3F3,$3F0
        dc.w    $3ED,$3EA,$3E6,$3E2,$3DD,$3D8,$3D3,$3CE,$3C8,$3C2,$3BC
        dc.w    $3B5,$3AF,$3A7,$3A0,$398,$390,$388,$380,$377,$36E,$364
        dc.w    $35B,$351,$347,$33C,$332,$327,$31C,$310,$305,$2F9,$2ED
        dc.w    $2E1,$2D4,$2C7,$2BA,$2AD,$2A0,$292,$284,$276,$268,$25A
        dc.w    $24B,$23D,$22E,$21F,$20F,$200,$1F0,$1E1,$1D1,$1C1,$1B1
        dc.w    $1A0,$190,$180,$16F,$15E,$14D,$13C,$12B,$11A,$109,$F8
        dc.w    $E6,$D5,$C3,$B2,$A0,$8F,$7D,$6B,$59,$47,$36,$24,$12,$0 
        
        ;When we go beyond 90 degrees, we are going to read the values from the sin table
                      
SinTable:       ;Starting at sin(0) until sin(90) -> times the value by 2^10 (into hex)
        dc.w    $0,$12,$24,$36,$47,$59,$6B,$7D,$8F,$A0,$B2,$C3,$D5,$E6
        dc.w    $F8,$109,$11A,$12B,$13C,$14D,$15E,$16F,$180,$190,$1A0
        dc.w    $1B1,$1C1,$1D1,$1E1,$1F0,$200,$20F,$21F,$22E,$23D,$24B
        dc.w    $25A,$268,$276,$284,$292,$2A0,$2AD,$2BA,$2C7,$2D4,$2E1
        dc.w    $2ED,$2F9,$305,$310,$31C,$327,$332,$33C,$347,$351,$35B
        dc.w    $364,$36E,$377,$380,$388,$390,$398,$3A0,$3A7,$3AF,$3B5
        dc.w    $3BC,$3C2,$3C8,$3CE,$3D3,$3D8,$3DD,$3E2,$3E6,$3EA,$3ED
        dc.w    $3F0,$3F3,$3F6,$3F8,$3FA,$3FC,$3FE,$3FF,$3FF,$400,$400
        ;Helping mirroring for beyond 90s
        dc.w    $400,$3FF,$3FF,$3FE,$3FC,$3FA,$3F8,$3F6,$3F3,$3F0,$3ED
        dc.w    $3EA,$3E6,$3E2,$3DD,$3D8,$3D3,$3CE,$3C8,$3C2,$3BC,$3B5
        dc.w    $3AF,$3A7,$3A0,$398,$390,$388,$380,$377,$36E,$364,$35B
        dc.w    $351,$347,$33C,$332,$327,$31C,$310,$305,$2F9,$2ED,$2E1
        dc.w    $2D4,$2C7,$2BA,$2AD,$2A0,$292,$284,$276,$268,$25A,$24B
        dc.w    $23D,$22E,$21F,$20F,$200,$1F0,$1E1,$1D1,$1C1,$1B1,$1A0
        dc.w    $190,$180,$16F,$15E,$14D,$13C,$12B,$11A,$109,$F8,$E6
        dc.w    $D5,$C3,$B2,$A0,$8F,$7D,$6B,$59,$47,$36,$24,$12,$0       























*~Font name~Courier New~
*~Font size~8~
*~Tab type~1~
*~Tab size~4~
