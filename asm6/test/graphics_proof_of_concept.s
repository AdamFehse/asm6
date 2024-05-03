.data
#####################################################
# Adam Fehse
#
# This is a galactic shooter clone. You contorl a ship
# that shoots lasers at enemies to destroy them. 
#
# assumes a 64x64 display.  
# To set this up, do the following steps:
#    - Tools->Bitmap Display
#    - Set "Unit width/height in pixels" to 8
#    - Set "Display width/height in pixels" to 512
#    - Set "Base Address for display" to static data
#    - Click "Connect to MIPS" *after* the rest are set
#
# You can contorl the ship with w,a,s,d. For up, left, down, right.
# Spacebar will shoot the laser. 
#
# Displayer buffer = 16384
#######################################################

DISPLAY:
	.space  16384
END_OF_DISPLAY:
.text

#################################################
# The main function will simply load the display
# buffer into t7.
#
# Registers used:
# t7 = display buffer
##################################################
main:
	la	$t7, DISPLAY		# inital load of display buffer

#################################################
# The game_loop() will handle all input and route
# the input strings to the appropriate move 
# functions.
#
# game_loop; // while ture
#  t0 = control;
#  t8 = loop delay count;
#  playerBg();
#  background_TOP();
#  background_BOTTOM();
#  outer_loop:
#     t1 = input
#     handleInput();
#     delay()
#
# Registers used:
# t0 - control bit
# t8 - delay loop count
# t1 - read control bit
# t2 - input bits (user input asdw)
# t6 - player color
# t7 - display buffer
# v0 - print messeges
# 
##################################################
game_loop:
	lui     	$t0, 0xffff
	addi    	$t8, $zero,1
	sll     	$t8, $zero, 30    		# LOOP_COUNT = 2^20
	jal 	playerbg	  		# player scene
	jal	background_TOP	  	# top scenery
	jal 	background_BOTTOM 		# Bottom scene

OUTER_LOOP:
	
	lw      $t1, 0($t0)      		# read control register
	andi    $t1, $t1,0x1     		# mask off all but bit 0 (the 'ready' bit)
.data
NOT_READY_MSG: .asciiz "Ready bit is zero, looping until I find something else...\n"
.text
	bne     $t1,$zero, READY
	addi    $t6, $zero, 0x00fff7            	# teal
	sw      $t6, 7544($t7)	           # store player in pixel
	sw      $t6, 7796($t7)	           # store player in pixel
	sw      $t6, 7804($t7)	           # store player in pixel
	# print_str(NOT_READY_MSG)
	addi    $v0, $zero,4
	la      $a0, NOT_READY_MSG
	syscall
##
# No inputs detected and will loop until an input
# is detected.
##
NOT_READY_LOOP:
	lw      $t1, 0($t0)      		# read control register
	andi    $t1, $t1,0x1    		# mask off all but bit 0 (the 'ready' bit)
	beq     $t1,$zero, NOT_READY_LOOP

##
# An input has been detected and will be further processed
# if it is in a,s,d,w.
##
READY:
	# read the actual typed character
	lw      $t1, 4($t0)
	
	# Check if the character is 'a'
	addi    $t2 $zero, 97           		# ASCII value of 'a'
	beq     $t1, $t2, handleA		# Branch if the character is 'a'
	
	addi    $t2 $zero, 100          		# ASCII value of 'd'
	beq     $t1, $t2, handleB		# Branch if the character is 'd'
	
	addi    $t2 $zero, 32           		# ASCII value of ' '
	beq     $t1, $t2, handleC		# Branch if the character is ' '
	
	addi    $t2 $zero, 115          		# ASCII value of 's'
	beq     $t1, $t2, handleS		# Branch if the character is 's'
	
	addi    $t2 $zero, 119          		# ASCII value of 'w'
	beq     $t1, $t2, handleW		# Branch if the character is 'w'
	
	j DELAY_LOOP
	
###########################################################
# The handleA function will move the space ship to the left.
# it does so by first coling the cell we are moving to,
# then uncolring the cell we just left. By adding some
# delay by using syscall 32 it makes it look smooth.
# We also call the background functions to simulate 
# movement.
# We off set by +-4 to move hortizonally.
#
# Regeisters used:
# t6 - color
# t3 - i (loop counter)
# t7 - frame buffer
##########################################################
handleA:
	addi    $t6, $zero, 0x00fff7            	# Teal
	addiu    $t3, $zero, 1
inner_left:
	beq     $t3, $zero, after_inner_left 
	addi    $t6, $zero, 0x00fff7            # teal
		
	sw      $t6, 7540($t7)	       # store player in pixel
	sw      $t6, 7792($t7)	       # store player in pixel
	sw      $t6, 7800($t7)	       # store player in pixel
		
	addi    $v0, $zero, 32	       # 32 = sleep
	addiu   $a0, $zero, 30	       # delay in ms
	syscall
	addi    $t6, $zero, 0x000               # blk
		
	sw      $t6, 7544($t7)	       # store player in pixel
	sw      $t6, 7796($t7)	       # store player in pixel
	sw      $t6, 7804($t7)	       # store player in pixel
		
	add     $t7, $t7, -4		       # move ptr left
	addi    $t3, $t3, -1		       # i--
	jal     background_TOP	       # player scene
	jal     background_BOTTOM 	       # Bottom scene
	j       inner_left
			
after_inner_left:
	addi    $t6, $zero, 0x00fff7            # teal
	sw      $t6, 7544($t7)	       # store player in pixel
	sw      $t6, 7796($t7)	       # store player in pixel
	sw      $t6, 7804($t7)	       # store player in pixel
 	j DELAY_LOOP
 				
###########################################################
# The handleB function will move the space ship to the left.
# it does so by first coling the cell we are moving to,
# then uncolring the cell we just left. By adding some
# delay by using syscall 32 it makes it look smooth.
# We also call the background functions to simulate 
# movement.
# We off set by +-4 to move hortizonally.
#
# Regeisters used:
# t6 - color
# t3 - i (loop counter)
# t7 - frame buffer
##########################################################
handleB:
	addiu    $t3, $zero, 1
inner_right:
		beq     $t3, $zero, after_inner_right 
		addi    $t6, $zero, 0x00fff7            # teal
		
		sw      $t6, 7548($t7)	       # store player in pixel
		sw      $t6, 7800($t7)	       # store player in pixel
		sw      $t6, 7808($t7)	       # store player in pixel
		
		
		addi	$v0, $zero, 32	       # 32 = sleep
		addiu   $a0, $zero, 30	       # delay in ms
		syscall
		addi    $t6, $zero,  0x0000   	       # black
		
		sw      $t6, 7544($t7)	       # store player in pixel
		sw      $t6, 7796($t7)	       # store player in pixel
		sw      $t6, 7804($t7)	       # store player in pixel
		
		add     $t7, $t7, 4		       # move ptr left
		addi    $t3, $t3, -1		       # i--
		jal 	background_TOP	       # player scene
		jal 	background_BOTTOM 	       # Bottom scene
		j	inner_right
	
after_inner_right:
		addi    $t6, $zero, 0x00fff7            # teal
		sw      $t6, 7544($t7)	       # store player in pixel
 		j DELAY_LOOP
 				
###########################################################
# The handleC function will shoot the laser.
# We use the same method as the other movement functions,
# except we offset by 512 so that we shoot vertically.
# Then we ugain uncolor the laser so it looks like
# it is a shot and not a beam.
#
# Delay by using syscall 32 it makes it look smooth.
#
# We also call the background functions to simulate 
# movement.
#
# Regeisters used:
# a0 - random color
# t3 - i (loop counter)
# t7 - frame buffer
# t6 - black color
########################################################## 	
handleC:
	addiu    $t3, $zero, 7
	inner_C:
		jal     generateRandomColorLASER
		beq     $t3, $zero, after_inner_C
		sw      $a0, 7032($t7)	                # store player in pixel
		addi    $v0, $zero, 32		     # 32 = sleep
		addiu   $a0, $zero, 15		     # delay in ms
		syscall
		jal     generateRandomColorLASER
		sw      $a0, 7032($t7)	                # store player in pixel
		addi	$v0, $zero, 32	     	     # 32 = sleep
		addiu   $a0, $zero, 30		     # delay in ms
		syscall
		addi    $t6, $zero, 0x000000          	     # black
		sw      $t6, 7032($t7)	                # store player in pixel
		add     $t7, $t7, -512		     # move ptr 
		addi    $t3, $t3, -1			     # i--
		j	inner_C
	
after_inner_C:
		addiu    $t3, $zero, 7
inner_C2:
		beq     $t3, $zero, after_inner_C2
		addi    $t6, $zero, 0x00000             # blk
		sw      $t6, 7800($t7)	       # store player in pixel
		add     $t7, $t7, 512		       # move ptr 
		jal     background_TOP	       # player scene
		addi    $t3, $t3, -1		       # i--
		j       inner_C2

		
after_inner_C2:	
		addi    $t6, $zero, 0x00fff7            # teal
		sw      $t6, 7544($t7)	       # store player in pixel
 		j DELAY_LOOP	

###########################################################
# The handleS function will move the space ship down.
# It does so by first coloring the cell we are moving to,
# then uncolring the cell we just left. By adding some
# delay by using syscall 32 it makes it look smooth.
# We also call the background functions to simulate 
# movement. We off set by +-512 to move vertically.
#
# Regeisters used:
# t6 - color
# t3 - i (loop counter)
# t7 - frame buffer
##########################################################						
handleS:
	addiu    $t3, $zero, 5
	inner_S:
		beq     $t3, $zero, after_inner_S
		addi    $t6, $zero, 0x00fff7            # Teal
		
		sw      $t6, 7800($t7)	       # store player in pixel
		sw      $t6, 8052($t7)	       # store player in pixel
		sw      $t6, 8060($t7)	       # store player in pixel
		
		
		addi	$v0, $zero, 32	       # 32 = sleep
		addiu   $a0, $zero, 30	       # delay in ms
		syscall
		addi    $t6, $zero,  0x0000             # blck
		
		sw      $t6, 7544($t7)	       # store player in pixel
		sw      $t6, 7796($t7)	       # store player in pixel
		sw      $t6, 7804($t7)	       # store player in pixel
		
		
		add     $t7, $t7, 256		       # move ptr left
		addi    $t3, $t3, -1		       # i--
		jal 	background_TOP	       # player scene
		jal 	background_BOTTOM 	       # Bottom scene
		j	inner_S
	
after_inner_S:
 		addi    $t6, $zero, 0x00fff7            # teal
		sw      $t6, 7544($t7)	       # store player in pixel
 		j DELAY_LOOP	

###########################################################
# The handleW function will move the space ship up.
# It does so by first coloring the cell we are moving to,
# then uncolring the cell we just left. By adding some
# delay by using syscall 32 it makes it look smooth.
# We also call the background functions to simulate 
# movement. We off set by +-512 to move vertically.
#
# Regeisters used:
# t6 - color
# t3 - i (loop counter)
# t7 - frame buffer
##########################################################	
handleW:
	addiu    $t3, $zero, 5
	inner_W:
		beq     $t3, $zero, after_inner_W 
		addi    $t6, $zero, 0x00fff7            # teal
		
		sw      $t6, 7288($t7)	       # store player in pixel
		sw      $t6, 7540($t7)	       # store player in pixel
		sw      $t6, 7548($t7)	       # store player in pixel
		
		addi    $v0, $zero, 32 	       # 32 = sleep
		addiu   $a0, $zero, 30	       # delay in ms
		syscall
		
		addi    $t6, $zero,   0x00000           # blk
		sw      $t6, 7544($t7)	       # store player in pixel
		sw      $t6, 7796($t7)	       # store player in pixel
		sw      $t6, 7804($t7)	       # store player in pixel
		
		add     $t7, $t7, -256	       # move ptr left
		addi    $t3, $t3, -1		       # i--
		jal 	background_TOP	       # player scene
		jal 	background_BOTTOM 	       # Bottom scene
		j	inner_W
	
	
after_inner_W:
 		addi    $t6, $zero, 0x00fff7            # teal
		sw      $t6, 7544($t7)	       # store player in pixel
 		j DELAY_LOOP
 				 					
###########################################################
# This loop will force a delay after processing input.
#
# Regeisters used:
# t2 - i
# t3 - i (loop counter)
# t7 - frame buffer
##########################################################	
DELAY_LOOP:
	addi    $t2, $zero,0     		       # i=0
	slt     $t3, $t2,$t8     		       # i < LOOP_COUNT
	beq     $t3,$zero, DELAY_DONE

	addi    $t2, $t2,1        		       # i++
	j       DELAY_LOOP
	
###################################
# Back to the beggiging of the loop
###################################
DELAY_DONE:
	j       OUTER_LOOP
	
##########################################################################
# Here we begin generating the enemies, then the top and bottom backgrouns.
# The enemies will spawn in the center/topish section of the playing field
# and be randomly dispered throughout that area. 
#########################################################################

##########################################################
# playerbg() generates the enemies using a rondomly 
# generated number (syscall 42) then adding that as 
# an offset to the adisplay buffer.
#
# playerbg()
#	a = displayBuffer/4	
#	b = 256/4
#	x = randomInt
# 	ret val  = (16384 / 4) + (256 / 4) + x
#	return ret
#
# Registers used:
# t8 - Number of enemies
# t0 - display buffer (int)
# t1 - 256 / 2
# t2 - result * 4
# a1 - upperbound
# t3 - random offset
# t9 - display buffer 
# a0 - result
##########################################################
playerbg:
	addiu $sp, $sp, -52 	# allocate stack space -- default of 24 here
	sw $fp, 0($sp) 	# save caller�s frame pointer
	sw $ra, 4($sp) 	# save return address
	addiu $fp, $sp, 48 	# setup main�s frame pointer

    	# Store them t's
    	sw $t0, 44($sp)       # Save temporary register $t0
    	sw $t1, 40($sp)       # Save temporary register $t0
    	sw $t2, 36($sp)       # Save temporary register $t0
    	sw $t3, 32($sp)       # Save temporary register $t0
    	sw $t4, 28($sp)       # Save temporary register $t0
    	sw $t5, 24($sp)       # Save temporary register $t0
    	sw $t6, 20($sp)       # Save temporary register $t0
    	sw $t7, 16($sp)       # Save temporary register $t0
    	sw $t8, 12($sp)       # Save temporary register $t0
    	sw $t9, 8($sp)        # Save temporary register $t0
    	
  	addiu	$t8, $zero, 20		# how mnay enemies
genRandom:

  	beq  	$t8, $zero, AFTER_fg_inner
	# Divide 16384 by 4
	li $t0, 16384
	srl $t0, $t0, 2  			# $t0 = 16384 / 4

	# Divide 256 by 4
	li $t1, 256
	srl $t1, $t1, 2  			# $t1 = 256 / 4

	# Get the random value for x using syscall 42
	addi	$v0, $zero, 42		# random int 
	addi	$a1, $zero, 1000		# upper bound
	syscall
	add	$t2, $zero, $a0		# random X
	sll        $t2, $t2, 2   		# multiple by 4
	
	# Calculate the expression
	add 	$t3, $t0, $t1  		# $t3 = (16384 / 4) + (256 / 4)
	add 	$t3, $t3, $t2  		# $t3 = (16384 / 4) + (256 / 4) + x

	la      	$t9, DISPLAY
	add     	$t9, $t9, $t3
	addi    	$t9, $t9, -8
	jal	generateRandomColorEASTER
	sw   	$a0, 0($t9)
	addi    $t8, $t8, -1
	j genRandom

AFTER_fg_inner:
    	# load them t's
    	lw $t0, 44($sp)       # Save temporary register $t0
    	lw $t1, 40($sp)       # Save temporary register $t0
    	lw $t2, 36($sp)       # Save temporary register $t0
    	lw $t3, 32($sp)       # Save temporary register $t0
    	lw $t4, 28($sp)       # Save temporary register $t0
   	lw $t5, 24($sp)       # Save temporary register $t0
    	lw $t6, 20($sp)       # Save temporary register $t0
   	lw $t7, 16($sp)       # Save temporary register $t0
    	lw $t8, 12($sp)       # Save temporary register $t0
    	lw $t9, 8($sp)        # Save temporary register $t0


	lw $ra, 4($sp) 	# get return address from stack
	lw $fp, 0($sp) 	# restore the caller�s frame pointer
	addiu $sp, $sp, 52 	# restore the caller�s stack pointer
	jr $ra 		# return to caller�s code
	
##################################################
# Background top control the top of the play area. 
# It fills the area with hues of blue by calling 
# generateRandomColorOCEAN.
#
# GenerateScene():
#	a = framebuffer;
#	i = 0 
#	while i <= 0;
#	    fillPixal(a);	
#	    a ++;
#	    i --;
#
#
# Registers used: 
# t8 = i
# t0 = frame buffer
# a0 = random hex color
##################################################
background_TOP:
	addiu $sp, $sp, -52 	# allocate stack space -- default of 24 here
	sw $fp, 0($sp) 	# save caller�s frame pointer
	sw $ra, 4($sp) 	# save return address
	addiu $fp, $sp, 48 	# setup main�s frame pointer

    	# Store  t's
   	sw $t0, 44($sp)       # Save temporary register $t0
    	sw $t1, 40($sp)       # Save temporary register $t0
    	sw $t2, 36($sp)       # Save temporary register $t0
    	sw $t3, 32($sp)       # Save temporary register $t0
    	sw $t4, 28($sp)       # Save temporary register $t0
    	sw $t5, 24($sp)       # Save temporary register $t0
    	sw $t6, 20($sp)       # Save temporary register $t0
    	sw $t7, 16($sp)       # Save temporary register $t0
    	sw $t8, 12($sp)       # Save temporary register $t0
    	sw $t9, 8($sp)        # Save temporary register $t0
    	
bg_top_loop:
	la	$t0, DISPLAY
	addi	$t8, $zero, 1024
bg_top_inner:
	jal	generateRandomColorOCEAN
	beq	$t8, $zero, AFTER_BG_TOP_INNER
	sw 	$a0, 0($t0)
	add	$t0, $t0, 4
	addi	$t8, $t8, -1
	j bg_top_inner
    
AFTER_BG_TOP_INNER:
       	# load t's
    	lw $t0, 44($sp)       # Save temporary register $t0
    	lw $t1, 40($sp)       # Save temporary register $t0
    	lw $t2, 36($sp)       # Save temporary register $t0
    	lw $t3, 32($sp)       # Save temporary register $t0
    	lw $t4, 28($sp)       # Save temporary register $t0
    	lw $t5, 24($sp)       # Save temporary register $t0
    	lw $t6, 20($sp)       # Save temporary register $t0
    	lw $t7, 16($sp)       # Save temporary register $t0
    	lw $t8, 12($sp)       # Save temporary register $t0
    	lw $t9, 8($sp)        # Save temporary register $t0


	lw $ra, 4($sp) 	# get return address from stack
	lw $fp, 0($sp) 	# restore the caller�s frame pointer
	addiu $sp, $sp, 52 	# restore the caller�s stack pointer
	jr $ra 		# return to caller�s code
##################################################
# Background_BOTTOM controls the bottom of the play area. 
# It fills the area with hues of blue by calling 
# generateRandomColorOCEAN.
#
# GenerateScene():
#	a = framebuffer;
#	i = 0 
#	while i <= 0;
#	    fillPixal(a);	
#	    a ++;
#	    i --;
#
# Registers used: 
# t8 = i
# t0 = frame buffer
# a0 = random hex color result
##################################################
background_BOTTOM:
	addiu $sp, $sp, -52 	# allocate stack space -- default of 24 here
	sw $fp, 0($sp) 	# save caller�s frame pointer
	sw $ra, 4($sp) 	# save return address
	addiu $fp, $sp, 48 	# setup main�s frame pointer

    	# Store  t's
   	sw $t0, 44($sp)      # Save temporary register $t0
    	sw $t1, 40($sp)      # Save temporary register $t0
    	sw $t2, 36($sp)      # Save temporary register $t0
    	sw $t3, 32($sp)      # Save temporary register $t0
    	sw $t4, 28($sp)      # Save temporary register $t0
    	sw $t5, 24($sp)      # Save temporary register $t0
    	sw $t6, 20($sp)      # Save temporary register $t0
    	sw $t7, 16($sp)      # Save temporary register $t0
    	sw $t8, 12($sp)      # Save temporary register $t0
    	sw $t9, 8($sp)       # Save temporary register $t0
    	
bg_bot_loop:
	la	$t0, DISPLAY
	addi	$t8, $zero, 1024
bg_bot_inner:
	jal	generateRandomColorOCEAN
	beq	$t8, $zero, AFTER_BG_BOT_INNER
	sw 	$a0, 12032($t0)
	add	$t0, $t0, 4
	addi	$t8, $t8, -1
	j bg_bot_inner
    
AFTER_BG_BOT_INNER:
       	# load  t's
    	lw $t0, 44($sp)       # Save temporary register $t0
    	lw $t1, 40($sp)       # Save temporary register $t0
    	lw $t2, 36($sp)       # Save temporary register $t0
    	lw $t3, 32($sp)       # Save temporary register $t0
    	lw $t4, 28($sp)       # Save temporary register $t0
    	lw $t5, 24($sp)       # Save temporary register $t0
    	lw $t6, 20($sp)       # Save temporary register $t0
    	lw $t7, 16($sp)       # Save temporary register $t0
    	lw $t8, 12($sp)       # Save temporary register $t0
    	lw $t9, 8($sp)        # Save temporary register $t0

	lw $ra, 4($sp) 	# get return address from stack
	lw $fp, 0($sp) 	# restore the caller�s frame pointer
	addiu $sp, $sp, 52 	# restore the caller�s stack pointer
	jr $ra 		# return to caller�s code
    
##################################################################
# generateRandomColor generates a random 24 bit color value 
# and stores that into a0. We mask the top bits of our number
# for the RED (bits 16-23) and shift right by 16 to get the number
# in the range we are looking for. Likewise for the GREEN and BLUE.
#
# Registers used: 
# a1 - max bound
# a0 - random number (from syscall)
# t0 - stores a0
# t1 - rgb, Red
# t2 - rgb, Green
# t3 - rgb, Blue
# t4 - rbg elements
# 
# Result will be stored in a0 in the end.
#################################################################
generateRandomColor:
	addiu $sp, $sp, -52 	# allocate stack space -- default of 24 here
	sw $fp, 0($sp) 	# save caller�s frame pointer
	sw $ra, 4($sp) 	# save return address
	addiu $fp, $sp, 48 	# setup main�s frame pointer

    	# Store t's
   	sw $t0, 44($sp)       # Save temporary register $t0
    	sw $t1, 40($sp)       # Save temporary register $t0
    	sw $t2, 36($sp)       # Save temporary register $t0
    	sw $t3, 32($sp)       # Save temporary register $t0
    	sw $t4, 28($sp)       # Save temporary register $t0
    	sw $t5, 24($sp)       # Save temporary register $t0
    	sw $t6, 20($sp)       # Save temporary register $t0
    	sw $t7, 16($sp)       # Save temporary register $t0
    	sw $t8, 12($sp)       # Save temporary register $t0
    	sw $t9, 8($sp)        # Save temporary register $t0
    	
    	li $a1, 16777216      # Set $a1 to the max bound for a 24-bit color (2^24 = 16777216)
    	li $v0, 42            # Generate a random number
    	syscall
    	move $t0, $a0         # Store the random number in $t0

    	# Extract RGB components from the random number
    	andi $t1, $t0, 0xFF0000    # Mask to extract the red component (bits 16-23)
    	srl $t1, $t1, 16           # Shift right to get the value in the range 0-255

    	andi $t2, $t0, 0x00FF00    # Mask to extract the green component (bits 8-15)
    	srl $t2, $t2, 8            # Shift right to get the value in the range 0-255

    	andi $t3, $t0, 0x0000FF    # Mask to extract the blue component (bits 0-7)

    	# Combine the RGB components into a single 24-bit color value
    	or $t4, $t1, $t2           # Combine red and green components
    	sll $t4, $t4, 8            # Shift left to make space for blue component
    	or $a0, $t4, $t3           # Combine with blue component
    	
           # prepare to jump back
    	lw $t0, 44($sp)       # Save temporary register $t0
    	lw $t1, 40($sp)       # Save temporary register $t0
    	lw $t2, 36($sp)       # Save temporary register $t0
    	lw $t3, 32($sp)       # Save temporary register $t0
    	lw $t4, 28($sp)       # Save temporary register $t0
    	lw $t5, 24($sp)       # Save temporary register $t0
    	lw $t6, 20($sp)       # Save temporary register $t0
    	lw $t7, 16($sp)       # Save temporary register $t0
    	lw $t8, 12($sp)       # Save temporary register $t0
    	lw $t9, 8($sp)        # Save temporary register $t0

	lw $ra, 4($sp) 	# get return address from stack
	lw $fp, 0($sp) 	# restore the caller�s frame pointer
	addiu $sp, $sp, 52 	# restore the caller�s stack pointer
	jr $ra 		# return to caller�s code
	
#######################################################
# Same as generateRandomColor except we use a differnt 
# masking process to extract a differnt pallete of RGB
# colors. By masking different values we can control
# the general range of hues we return. 
# This specifically generates pastel hues.
 
# Registers used: 
# a1 - max bound
# a0 - random number (from syscall)
# t0 - stores a0
# t1 - rgb, Red
# t2 - rgb, Green
# t3 - rgb, Blue
# t4 - rbg elements
# 
# Result will be stored in a0 in the end.
######################################################

generateRandomColorEASTER:
	addiu $sp, $sp, -52 	# allocate stack space -- default of 24 here
	sw $fp, 0($sp) 	# save caller�s frame pointer
	sw $ra, 4($sp) 	# save return address
	addiu $fp, $sp, 48 	# setup main�s frame pointer

    	# Store them t's
   	sw $t0, 44($sp)       # Save temporary register $t0
    	sw $t1, 40($sp)       # Save temporary register $t0
    	sw $t2, 36($sp)       # Save temporary register $t0
    	sw $t3, 32($sp)       # Save temporary register $t0
    	sw $t4, 28($sp)       # Save temporary register $t0
    	sw $t5, 24($sp)       # Save temporary register $t0
    	sw $t6, 20($sp)       # Save temporary register $t0
    	sw $t7, 16($sp)       # Save temporary register $t0
    	sw $t8, 12($sp)       # Save temporary register $t0
    	sw $t9, 8($sp)        # Save temporary register $t0
    	li $a1, 16777216      # Set $a1 to the max bound for a 24-bit color (2^24 = 16777216)
    	li $v0, 42            # Generate a random number
    	syscall
    	move $t0, $a0         # Store the random number in $t0

    	# Extract RGB components from the random number
    	andi $t1, $t0, 0x000000    # Mask to extract the red component (bits 16-23)
    	srl $t1, $t1, 16           # Shift right to get the value in the range 0-255

    	andi $t2, $t0, 0xffffff    # Mask to extract the green component (bits 8-15)
    	srl $t2, $t2, 8            # Shift right to get the value in the range 0-255

    	andi $t3, $t0, 0x0000ff    # Mask to extract the blue component (bits 0-7)  (ADJUST THIS FOR MORE BROWNS)

    	# Combine the RGB components into a single 24-bit color value
    	or $t4, $t1, $t2           # Combine red and green components
    	sll $t4, $t4, 8            # Shift left to make space for blue component
    	or $a0, $t4, $t3           # Combine with blue component
    	
           # load  t's
    	lw $t0, 44($sp)       # Save temporary register $t0
    	lw $t1, 40($sp)       # Save temporary register $t0
    	lw $t2, 36($sp)       # Save temporary register $t0
    	lw $t3, 32($sp)       # Save temporary register $t0
    	lw $t4, 28($sp)       # Save temporary register $t0
    	lw $t5, 24($sp)       # Save temporary register $t0
    	lw $t6, 20($sp)       # Save temporary register $t0
    	lw $t7, 16($sp)       # Save temporary register $t0
    	lw $t8, 12($sp)       # Save temporary register $t0
    	lw $t9, 8($sp)        # Save temporary register $t0

	lw $ra, 4($sp) 	# get return address from stack
	lw $fp, 0($sp) 	# restore the caller�s frame pointer
	addiu $sp, $sp, 52 	# restore the caller�s stack pointer
	jr $ra 		# return to caller�s code

############################################################
# Same as generateRandomColor except we use a differnt 
# masking process to extract a differnt pallete of RGB
# colors. This specifically generates blue hues. 
#
# Registers used: 
# a1 - max bound
# a0 - random number (from syscall)
# t0 - stores a0
# t1 - rgb, Red
# t2 - rgb, Green
# t3 - rgb, Blue
# t4 - rbg elements
# 
# Result will be stored in a0 in the end.
###########################################################
generateRandomColorOCEAN:
	addiu $sp, $sp, -52 	# allocate stack space -- default of 24 here
	sw $fp, 0($sp) 	# save caller�s frame pointer
	sw $ra, 4($sp) 	# save return address
	addiu $fp, $sp, 48 	# setup main�s frame pointer

    	# Store t's
   	sw $t0, 44($sp)       # Save temporary register $t0
    	sw $t1, 40($sp)       # Save temporary register $t0
    	sw $t2, 36($sp)       # Save temporary register $t0
    	sw $t3, 32($sp)       # Save temporary register $t0
    	sw $t4, 28($sp)       # Save temporary register $t0
    	sw $t5, 24($sp)       # Save temporary register $t0
    	sw $t6, 20($sp)       # Save temporary register $t0
    	sw $t7, 16($sp)       # Save temporary register $t0
    	sw $t8, 12($sp)       # Save temporary register $t0
    	sw $t9, 8($sp)        # Save temporary register $t0
    	li $a1, 16777216      # Set $a1 to the max bound for a 24-bit color (2^24 = 16777216)
    	li $v0, 42            # Generate a random number
    	syscall
    	move $t0, $a0         # Store the random number in $t0

    	# Extract RGB components from the random number
    	andi $t1, $t0, 0x000000    # Mask to extract the red component (bits 16-23)
    	srl $t1, $t1, 16           # Shift right to get the value in the range 0-255

    	andi $t2, $t0, 0x000000    # Mask to extract the green component (bits 8-15)
    	srl $t2, $t2, 8            # Shift right to get the value in the range 0-255

    	andi $t3, $t0, 0x0000ff    # Mask to extract the blue component (bits 0-7)

    	# Combine the RGB components into a single 24-bit color value
    	or $t4, $t1, $t2           # Combine red and green components
    	sll $t4, $t4, 8            # Shift left to make space for blue component
    	or $a0, $t4, $t3           # Combine with blue component
    	
    	
           # load t's prepare for exit
    	lw $t0, 44($sp)       # Save temporary register $t0
    	lw $t1, 40($sp)       # Save temporary register $t0
    	lw $t2, 36($sp)       # Save temporary register $t0
    	lw $t3, 32($sp)       # Save temporary register $t0
    	lw $t4, 28($sp)       # Save temporary register $t0
    	lw $t5, 24($sp)       # Save temporary register $t0
    	lw $t6, 20($sp)       # Save temporary register $t0
    	lw $t7, 16($sp)       # Save temporary register $t0
    	lw $t8, 12($sp)       # Save temporary register $t0
    	lw $t9, 8($sp)        # Save temporary register $t0

	lw $ra, 4($sp) 	# get return address from stack
	lw $fp, 0($sp) 	# restore the caller�s frame pointer
	addiu $sp, $sp, 52 	# restore the caller�s stack pointer
	jr $ra 		# return to caller�s code


##################################################
# Same as generateRandomColor except we use a differnt 
# masking process to extract a differnt pallete of RGB
# colors. This specifically generates deep reds some blacks. 
#
# Registers used: 
# a1 - max bound
# a0 - random number (from syscall)
# t0 - stores a0
# t1 - rgb, Red
# t2 - rgb, Green
# t3 - rgb, Blue
# t4 - rbg elements
# 
# Result will be stored in a0 in the end.
##################################################
generateRandomColorLASER:
	addiu $sp, $sp, -52 # allocate stack space -- default of 24 here
	sw $fp, 0($sp) # save caller�s frame pointer
	sw $ra, 4($sp) # save return address
	addiu $fp, $sp, 48 # setup main�s frame pointer

    	# Store them t's
   	sw $t0, 44($sp)      # Save temporary register $t0
    	sw $t1, 40($sp)      # Save temporary register $t0
    	sw $t2, 36($sp)      # Save temporary register $t0
    	sw $t3, 32($sp)       # Save temporary register $t0
    	sw $t4, 28($sp)       # Save temporary register $t0
    	sw $t5, 24($sp)       # Save temporary register $t0
    	sw $t6, 20($sp)       # Save temporary register $t0
    	sw $t7, 16($sp)       # Save temporary register $t0
    	sw $t8, 12($sp)       # Save temporary register $t0
    	sw $t9, 8($sp)        # Save temporary register $t0
    	li $a1, 16777216      # Set $a1 to the max bound for a 24-bit color (2^24 = 16777216)
    	li $v0, 42            # Generate a random number
    	syscall
    	move $t0, $a0         # Store the random number in $t0

    	# Extract RGB components from the random number
    	andi $t1, $t0, 0x000000    # Mask to extract the red component (bits 16-23)
    	srl $t1, $t1, 16           # Shift right to get the value in the range 0-255

    	andi $t2, $t0, 0x0000ff    # Mask to extract the green component (bits 8-15)
    	srl $t2, $t2, 8            # Shift right to get the value in the range 0-255

    	andi $t3, $t0, 0xff0000    # Mask to extract the blue component (bits 0-7)

    	# Combine the RGB components into a single 24-bit color value
    	or $t4, $t1, $t2           # Combine red and green components
    	sll $t4, $t4, 8            # Shift left to make space for blue component
    	or $a0, $t4, $t3           # Combine with blue component
    	
           # load t's
    	lw $t0, 44($sp)       # Save temporary register $t0
    	lw $t1, 40($sp)       # Save temporary register $t0
    	lw $t2, 36($sp)       # Save temporary register $t0
    	lw $t3, 32($sp)       # Save temporary register $t0
    	lw $t4, 28($sp)       # Save temporary register $t0
    	lw $t5, 24($sp)       # Save temporary register $t0
    	lw $t6, 20($sp)       # Save temporary register $t0
    	lw $t7, 16($sp)       # Save temporary register $t0
    	lw $t8, 12($sp)       # Save temporary register $t0
    	lw $t9, 8($sp)        # Save temporary register $t0

	lw $ra, 4($sp) 	# get return address from stack
	lw $fp, 0($sp) 	# restore the caller�s frame pointer
	addiu $sp, $sp, 52 	# restore the caller�s stack pointer
	jr $ra 		# return to caller�s code
