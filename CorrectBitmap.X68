*-----------------------------------------------------------
* Title      : Bitmap Subroutine
* Written by : Aashish Subramanian
* Date       : 5/24/2023
* Description: This is a program that outputs a 32 and 24 bitmap. The user will have to pass in paramters in order to print out
              ;The wanted bitmap, either a chunk of it or all of it. These paramters work for a 32 bit, however for 24 bit, 
              ;only the full bitmap wills how, no chunking or position updating is there
              ;The Paramters you pass for the 32 bit will check if they are allowed. For example, if you give an Starting X Position
              ;for where you want your chunk to look at, but it is outisde of the original bitmap, an error will show, same goes for the Y
              ;The chunk that you want to use will have to be within the bounds of where you starting X position of chunk is and the width of the 
              ;original bitmap. This goes for the heigt chunk as well. For the output position, when you put coordinates that are outisde of the screen
              ;Such as when a bitmap is half draw in and out of the screen, that was intentially done to show that the bitmap is still printing, you just are 
              ;not fully seeing it.              

;LOCAL VARIABLES
YOutput         EQU     4
XOutput         EQU     8
ChunkHeight     EQU     12
ChunkWidth      EQU     16
YChunk          EQU     20
XChunk          EQU     24


DisplayString   EQU     14         
SetPenColor     EQU     80
DrawPixel       EQU     82
SetScreenSize   EQU     33
BitmapCheck     EQU     $424D
WidthOffset     EQU     $12
HeightOffset    EQU     $16
NumOfBitsOS     EQU     $18
NumOfBits       EQU     $1C
PixDataBegin    EQU     $0A
ScreenRes       EQU     (1024*$10000+768)
SizeOfHeader    EQU     $0E
SizeOfOS        EQU     $0C
TwentyFour      EQU     $18



    
DrawBitmap:
    ;Start here
    JSR     BitMapInfoHeader

    MOVE.l  d5, d2                  ;d2 right now is going to store the original width of the image
    MOVE.l  d6, d3                  ;D3 will be used to hold the original height of the image
    MOVE.l  ChunkWidth(sp), d5      ;D5 stores the chunk width
    MOVE.l  ChunkHeight(sp), d6     ;D6 stores the chunk height
            
    ADD.l   d6, YChunk(sp)          ;Updating the Y cordinate where we want our chunk to look at to be at the bottom left of chunk  

    SUB.b   #$1, d6                 ;d6 prints one extra row by mistake, this fixes it)

                                ;Now that we have initializzed everything, lets get the offset of the byte where thr bitmap is starting
    MOVE.b  PixDataBegin(a0), d0         ;Put the offset we recieved in d0 and into an address register to start working on the colors
       
    LEA     (a0,d0), a1         ;Get the address of where the pixel data starts
    
    MOVE.l  (a0,d0),d1          ;store the pixel data from the starting address into d1 long. -Starting point  
        
    *Get the corresponding Blue Green Red values     
    LSR.l   #8, d1              ;This sets the Pen Color
    MOVE.l  #SetPenColor, d0
    TRAP    #15

ThirtyTwoBitMap:    
    MOVE.l  d2, d7              ;d7 Stores the original width of the image
    MOVE.l  d3, d1              ;d1 is used as a Y cord checker and stores currently the original height of the image
    CLR.l   d3                  ;USE d3 as a x cord checker
                                   
    JSR     ChunkPrinter
    
    RTS     
*------------------
BitMapInfoHeader:               *Have to use Endian change for values for Easy68K to read
    
    MOVE.l  WidthOffset(a0), d0         ;The bitmap width in pixels 
    JSR     EndianSwitch
    MOVE.l  d0, d5

        
    MOVE.l  HeightOffset(a0), d0         ;The bitmap height in pixels
    JSR     EndianSwitch
    MOVE.l  d0, d6

    MOVE.w  NumOfBits(a0), d0         ;The Number of bits per pixels
    LSR.w   #8, d0
    MOVE.l  d0, d7          
      
    RTS   
*------------------
EndianSwitch:
    ROR.w   #8, d0              ;Right Rotating the current lower word (this is just to keep the value correct because if we read a number like 12 34 10 00, we want our register to read 00 10 34 12)
                                ;This code is just to make sure the lower word is rotated,, but usually the lower word would originally just be 00 00
    SWAP    d0                  ;Swapping the upper and lower word in d0
    ROR.w   #$8, d0             ;Right shift rotating the word 8 bits to be in the correct Endian form
    RTS
*------------------

***************CHUNKER CODE for 32 bit********************

ChunkPrinter:  
    ;Our stack pointer has bas pushed back so we have to put it back to original position
    ADD.l   #$4, sp
    MOVE.l  YOutput(sp), d4               ;Putting the Y position where we want our chunk to be outputed on the screen
    ADD.l   d6, d4          
                            ;Check if the Y posiiton is equal to the starting position, if true then go find the x 
CheckYChunk:                         ;if not true, then skip all the pixels and go to next line
    CMP.l   YChunk(sp), d1            ;Comparing if we have reached the bottom left of our wanted chunk, (a4 holds the starting y position + chunk height)
    BEQ     FindXPosition

UpdateToNextRow
    ;Since we are not in the correct row, we want to skip all the pixels in the row we are at
    ;To do this we need to move the amount of pixels that are in one row
    ;Because we are not in the correct row, we have to make update a1 to go into the next row
    ;Since we have a certain amount of pixels for the width (coming from d7), and each pixel has RGBA values, so each pixel has 4 components to it
    ;Therefore we need to update A1 by 4 * the amount of pixels 
    MOVE.l  d7, d2                  ;Use d2 as the offset register to help us update a1 for the correct pixel data
    LSL.l   #2, d2
    LEA.l   (a1,d2), a1             ;Get the address of where the pixel data starts, MAYBE MULT BY 4
                                    ;If this doesn't work use
    ;Now a1 is storing the first pixel in the first row, lets add 1 to d4 for the next row 
    SUB.l   #$00000001, d1              ;We want to check the next row now so decrease d1 counter
    BRA     CheckYChunk

FindXPosition
    ;Since we are on the correct row that starts the chunk, lets get to the pixel that has the correct x coordinate
    ;All we need to do is get the total amount of pixels from left edge to startingX and multiply by 4 to move a1 to the correct pixel data
    MOVE.l  XChunk(sp), d2                    ;d2 stores the amount of pixels from left of image to the left egde of chunk, (a2) holds the contents of what x position we want our chunk to get
    LSL.l   #2, d2                 
    LEA.l   (a1,d2), a1
    MOVE.l  XOutput(sp), d3               ;Putting the X position where we want our chunk to be outputed on the screen
                        
        
ChunkRowPrint:
    ;Now that we are at the correct pixel, lets start printing  
    ;We will get the pixel data and set the pen color from the pixel we are currently at
    MOVE.l  (a1), d1
    LSR.l   #8, d1              ;This sets the Pen Color
    MOVE.l  #SetPenColor, d0
    TRAP    #15                 
                                ;This will now print the correct pixel for the chunk
    MOVE.w  d3, d1              ;X = D1.W
    MOVE.w  d4, d2              ;Y = D2.W
    MOVE.l  #DrawPixel, d0
    TRAP    #15 

    ;Now that we printed the pixel, we have to print the rest of the pixels until our d3 has reached the width that is wanted for the chunk
    ;Lets first update address to the next pixel
    ADD.l   #4, a1
    ;Increment d3 to be on the next right pixel, (y stays the same)
    ADDI.l   #00000001,d3       ;X++, incrementing the width to the next position
    
    ;We have to check if d3 has reached the point where we want to stop printing the chunk in that row
    ;In order to do this, for each iteration, we will be decreasing d5 which holds the width, it keeps going until d5 is 0
    SUB.l   #1, d5
    CMPI.l  #00000000, d5       ;If d5 is 0, then we have printed all of the chunks row
    BNE     ChunkRowPrint
    
ChunkRowFinish:
    ;We can check if we have printed all the correct section for the chunk, if d6 is the height counter is 0, we are done
    CMP.l   #00000000, d6       ;Checking if d6 is 0, then we have printed the total height of the chunk, therefore we are done
    BEQ     FinishChunk

CalculationForRightEdgeDistance:
    MOVE.l  d7,d2
    SUB.l   ChunkWidth(sp), d2            ;a3 = WIDTH
    SUB.l   XChunk(sp), d2            ;a2 = STARTX

    ;Now that d2 stores the amount of pixels from the far right edge of chunk to the right edge of total image, we can update a1 to get the correct address
    LSL.l   #2, d2                
    LEA.l   (a1,d2), a1         ;Loads a1 to hold the first pixel in the row


    ;Since we are at the edge of a row, we must go to the next one and do same procedures until we want to finish the whole chunk
    SUB.l  #00000001,d4         ;Y--, decreasing the height to the next position
    CLR.l   d3
    SUB.l   #00000001,d6        ;d6 is storing the height of the chunk, we want to keep doing this until the counter (d6) is 0
                                ;When it is 0, then we have printed the whole chunk and can stop, we check if its 0 in the CorrectXPosition
                                
    MOVE.l  ChunkWidth(sp), d5            ;We want to reload d5 to be the width so we can keep doing the same operations until the end
    BRA     FindXPosition   

FinishChunk:
    RTS


BITMAP_DRAW:                          ;first instruction of program
    LEA     Image, a0           ;puts the image starting address into a0, (should have 424D to begin with)
    
    ;Pass in parameters to go into subroutine
    ;Using 6 local variables and passing those as parameters into the stack to use 
    MOVE.l  StartingXChunk, -(sp)     ;Starting X Position for Chunk
    MOVE.l  StartingYChunk, -(sp)     ;Starting Y Position for Chunk 
    MOVE.l  WidthChunk, -(sp)     ;Chunk Width
    MOVE.l  HeightChunk, -(sp)     ;Chunk Height
    MOVE.l  StartXOutput, -(sp)      ;Starting X Position for Output on Screen
    MOVE.l  StartYOutput, -(sp)     ;Starting Y Position for Output on Screen 
        
    JSR DrawBitmap
    
PROGRAM_END:
    ;Reset the stack points, pop the values
    ADD.l   #24, sp

    RTS         
    ;SIMHALT                     ;halt simulator
SET_UP_BACKGROUND:
    MOVE.l  #0, StartingXChunk
    MOVE.l  #0, StartingYChunk
    MOVE.l  #640, WidthChunk
    MOVE.l  #480, HeightChunk 
    MOVE.l  #0, StartXOutput
    MOVE.l  #0, StartYOutput
    
    RTS
   
ATTACKER_CHUNK:
    MOVE.l  #165, StartingXChunk
    MOVE.l  #340, StartingYChunk
    MOVE.l  #335, WidthChunk
    MOVE.l  #140, HeightChunk 
    MOVE.l  #165, StartXOutput
    MOVE.l  #340, StartYOutput
   
   RTS
   
* Put variables and constants here
Image:      INCBIN      "BitmapBackground.bmp"
StartingXChunk      dc.l    1
StartingYChunk      dc.l    1
WidthChunk          dc.l    1
HeightChunk         dc.l    1
StartXOutput        dc.l    1
StartYOutput        dc.l    1




NextLine            dc.b    '', 0

NotBitmap           dc.b    'The file is not a bitmap', 0
ErrorMessage        dc.b    'There is an ERROR with the inputs, Out of Bound coordinates', 0  

    ;END    START                ; last line of source











*~Font name~Courier New~
*~Font size~8~
*~Tab type~1~
*~Tab size~4~
