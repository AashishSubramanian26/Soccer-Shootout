*-----------------------------------------------------------
* Title      : Game Loop for Soccer Shootout
* Written by : Aashish Subramanian
* Date       : 7/17/2023
* Description: This is the game loop for Soccer Shootout
*-----------------------------------------------------------
    ORG    $1000
    INCLUDE     'TitleScreen.X68'
    INCLUDE     'BallInput.X68'
    INCLUDE     'BallMovement.X68'
    INCLUDE     'CollisionDetection.X68'
    INCLUDE     'RandomNumberGenerator.X68'
    INCLUDE     'DefendingMovement.X68'
    INCLUDE     'SevenSegmentLED.X68'
*------------------------    
UPDATE_BASED_FROM_INPUTS:   ;All the claculations for the ball movement and 
    MOVE.b  titleScreenOn, d0   ;If title screen is still on, we don't want to do any calculations
    BNE     SKIP_POINTER_UPDATES

    MOVE.b  resetFlag, d0       ;Reset Flag is set to 0 when we score so we can load in all the correct stuff for our next round
    BNE     SKIP_UPDATE_SETUP
    
    JSR     INITIALIZE_VARIABLES
    JSR     GET_STARTING_ANGLE
    JSR     GET_RANDOM_NUMBER
    JSR     SET_RANDOM_SPEED
    JSR     INITIALIZE_DEFENDER_LOCATION 
    
    BRA     SKIP_POINTER_UPDATES
    
SKIP_UPDATE_SETUP:  
    JSR     CALCULATE_DEFENDER_POSITION

    MOVE.b  hasKickedBall, d0       ;Checks if we have kicked the ball yet, if we haven't we need to move our pointer
    BEQ     NO_BALL_TO_UPDATE       ;Will continue if we have pressed, if we havent pressed space, we still wanna aim
    
    MOVE.b  ballIsKickedInitially, d0
    BEQ     NOT_INITIAL_KICK           
    
    JSR     FIND_XY_VELOCITY_COMPONENTS  ;This should only be called once
    JSR     SETUP_INITIAL_BALL
    BRA     SKIP_POINTER_UPDATES
    
NOT_INITIAL_KICK:   
    JSR     CHECK_FIELD_COLLISIONS
    MOVE.b  hasCollided, d0
    BNE     CHECK_LIVE_COUNTER            ;DECREASE LIFE COUNTER HERE
    
    ;Check if ball collided with the defender       ;Lose life
    JSR     CHECK_DEFENDER_COLLISIONS
    MOVE.b  hasCollided, d0
    BNE     CHECK_LIVE_COUNTER            ;DECREASE LIFE COUNTER HERE

    ;Check if ball collided with the goal           ;Increase score
    JSR     CHECK_GOAL_COLLISIONS
    
    JSR     UPDATE_SCORE_DIGITS
    
    JSR     CALCULATE_BALL_POSITION
      

    BRA     SKIP_POINTER_UPDATES
 
CHECK_LIVE_COUNTER:
    MOVE.l  totalLives, d0      ;Checking if the lives are 0 are not, if 0 then the game is over, and we turn on game over flag
    BNE     SKIP_POINTER_UPDATES
    
    MOVE.b  #1, gameOverFlag
    
    BRA     SKIP_POINTER_UPDATES
NO_BALL_TO_UPDATE:              ;When we haven't kicked yet, we just want to update our angle and find the X,Y for new line
    JSR     UPDATE_ANGLE
    JSR     FIND_XY_POINT

    
SKIP_POINTER_UPDATES:    
    RTS   
*------------------------     
RENDER_BASED_FROM_INPUTS:
    MOVE.b  titleScreenOn, d0       ;If title screen is still on, then we don't want to render anything else until space is pressed
    BNE     SKIP_KICK  
    
    JSR     CLEAR_SCREEN
   
    MOVE.b  GameOverFlag, d0        ;If the game over flag is high, we are done and want to display the score
    BNE     SKIP_KICK

    MOVE.b  hasCollided, d0         ;If we have collided, we need to render everything again from a reset state
    BNE     LEAVE_RENDER_LOOP       
   
    MOVE.b  resetFlag, d0           ;If we are currently resetting our game for the round, we only need to render a new initial line 
    BNE     SKIP_RENDER_SETUP

    JSR     DRAW_INITIAL_LINE
    
    BRA     SKIP_KICK
SKIP_RENDER_SETUP:    
    JSR     DRAW_DEFENDER
    JSR     DRAW_GOAL
    
    MOVE.b  hasKickedBall, d0
    BNE     DRAW_MOVING_BALL
    
    JSR     PRINT_SCORE
    JSR     PRINT_LIVES
       
    JSR     DRAW_ATTACKER
    JSR     DRAW_NEW_LINE
    
    BRA     SKIP_KICK    
        
DRAW_MOVING_BALL:
    JSR     DRAW_BALL
    JSR     PRINT_LIVES
    JSR     PRINT_SCORE
SKIP_KICK:
    JSR     SWAP_BUFFERS    
    
    MOVE.b  gameOverFlag, d0        ;If the game is over, then print out our score and end program
    BNE     END_GAME
    
    MOVE.b  titleScreenOn, d0       
    BEQ     LEAVE_RENDER_LOOP
    
    JSR     DRAW_TITLE_SCREEN
  
 
LEAVE_RENDER_LOOP
    RTS

END_GAME: 
    JSR     SHOW_RESULTS
    
    SIMHALT
*------------------------     
START:                  
    ;Initiailize Functions
    JSR     SET_DOUBLE_BUFFER
    JSR     FIND_DELTA_TIME
    JSR     FIRST_TIME_INTIALIZE_VARIABLES      ;This line will make sure everything works the first time the program runs/or any resets
   
GAME_LOOP:
    JSR     FIND_DELTA_TIME      ;Finding the change in time for each frame, to help us with each physics calculation
    
    JSR     HANDLE_INPUT         ;Set flags for either left or right to get the correct angle 
    
    JSR     UPDATE_BASED_FROM_INPUTS
    
    JSR     RENDER_BASED_FROM_INPUTS
    
    BRA     GAME_LOOP
    

* Put variables and constants here

    END    START        ; last line of source













*~Font name~Courier New~
*~Font size~8~
*~Tab type~1~
*~Tab size~4~
