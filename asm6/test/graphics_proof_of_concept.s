.data

# assumes a 64x64 display.  To set this up, do the following steps:
#    - Tools->Bitmap Display
#    - Set "Unit width/height in pixels" to 8
#    - Set "Display width/height in pixels" to 512
#    - Set "Base Address for display" to static data
#    - Click "Connect to MIPS" *after* the rest are set

DISPLAY:
	.space  16384
END_OF_DISPLAY:
.text


main:
	la	$t7, DISPLAY
game_loop:
	lui     $t0, 0xffff
	addi    $t8, $zero,1
	sll     $t8, $zero, 30    # LOOP_COUNT = 2^20
	jal 	playerbg	  # player scene
	jal	background_TOP	  # top scenery
	jal 	background_BOTTOM # Bottom scene

OUTER_LOOP:	
	lw      $t1, 0($t0)      # read control register
	andi    $t1, $t1,0x1     # mask off all but bit 0 (the 'ready' bit)


.data
NOT_READY_MSG: .asciiz "Ready bit is zero, looping until I find something else...\n"
.text
	bne     $t1,$zero, READY

	# print_str(NOT_READY_MSG)
	addi    $v0, $zero,4
	la      $a0, NOT_READY_MSG
	syscall

NOT_READY_LOOP:
	lw      $t1, 0($t0)      			 # read control register
	andi    $t1, $t1,0x1    			 # mask off all but bit 0 (the 'ready' bit)
	beq     $t1,$zero, NOT_READY_LOOP

READY:
	# read the actual typed character
	lw      $t1, 4($t0)
	
	# Check if the character is 'a'
	addi    $t2 $zero, 97           		        # ASCII value of 'a'
	beq     $t1, $t2, handleA				# Branch if the character is 'a'
	
	addi    $t2 $zero, 100           		        # ASCII value of 'd'
	beq     $t1, $t2, handleB				# Branch if the character is 'd'
	
	addi    $t2 $zero, 32           		        # ASCII value of ' '
	beq     $t1, $t2, handleC				# Branch if the character is ' '
	
	addi    $t2 $zero, 115           		        # ASCII value of 's'
	beq     $t1, $t2, handleS				# Branch if the character is 's'
	
	addi    $t2 $zero, 119           		        # ASCII value of 'w'
	beq     $t1, $t2, handleW				# Branch if the character is 'w'
	
	j DELAY_LOOP

handleA:
	addi    $t6, $zero, 0x00fff7            # Teal
	addiu    $t3, $zero, 1
	inner_left:
		beq     $t3, $zero, after_inner_left 
		addi    $t6, $zero, 0x00fff7            # teal
		sw      $t6, 7540($t7)	                # store player in pixel
		addi	$v0, $zero, 32			# 32 = sleep
		addiu   $a0, $zero, 30			# delay in ms
		syscall
		addi    $t6, $zero, 0x000               # blk
		sw      $t6, 7544($t7)	                # store player in pixel
		add     $t7, $t7, -4			# move ptr left
		addi    $t3, $t3, -1			# i--
		j	inner_left
			
after_inner_left:
 	j DELAY_LOOP
	
	
handleB:
	addiu    $t3, $zero, 1
	inner_right:
		beq     $t3, $zero, after_inner_right 
		addi    $t6, $zero, 0x00fff7             # teal
		sw      $t6, 7548($t7)	                # store player in pixel
		addi	$v0, $zero, 32			# 32 = sleep
		addiu   $a0, $zero, 30			# delay in ms
		syscall
		addi    $t6, $zero,  0x0000   	        # red
		sw      $t6, 7544($t7)	                # store player in pixel
		add     $t7, $t7, 4			# move ptr left
		addi    $t3, $t3, -1			# i--
		j	inner_right
	
after_inner_right:
	addi    $t6, $zero, 0x00fff7            # teal
	sw      $t6, 7544($t7)	                # store player in pixel
	addi    $t6, $zero, 0x00000             # blk
	sw      $t6, 7540($t7)	                # store player in pixel
 	j DELAY_LOOP		
 	
handleC:
	addiu    $t3, $zero, 5
	inner_C:
		beq     $t3, $zero, after_inner_C
		addi    $t6, $zero, 0x0000              # black
		sw      $t6, 7032($t7)	                # store player in pixel
		addi	$v0, $zero, 32			# 32 = sleep
		addiu   $a0, $zero, 25			# delay in ms
		syscall
		addi    $t6, $zero,  0x00fff7           # teal
		sw      $t6,  7544($t7)	                # store player in pixel
		addi	$v0, $zero, 32			# 32 = sleep
		addiu   $a0, $zero, 25			# delay in ms
		syscall
		addi    $t6, $zero,  0x0000             # set all hits black
		sw      $t6,  6776($t7)	                # store player in pixel
		add     $t7, $t7, -512		        # move ptr 
		addi    $t3, $t3, -1			# i--
		j	inner_C
	
after_inner_C:
		addiu    $t3, $zero, 5
inner_C2:
		beq     $t3, $zero, after_inner_C2
		addi    $t6, $zero, 0x0000              # blk
		sw      $t6, 7544($t7)	                # store player in pixel
		addi	$v0, $zero, 32			# 32 = sleep
		addiu   $a0, $zero, 25			# delay in ms
		syscall
		add     $t7, $t7, 512		        # move ptr 
		addi    $t3, $t3, -1			# i--
		j	inner_C2

		
after_inner_C2:	
	jal 	playerbg	 # player scene
	jal 	background_TOP	 # player scene
	jal 	background_BOTTOM # Bottom scene
	
 	j DELAY_LOOP	
		
handleS:
	addiu    $t3, $zero, 5
	inner_S:
		beq     $t3, $zero, after_inner_S
		addi    $t6, $zero, 0x00fff7            # Teal
		sw      $t6, 7800($t7)	                # store player in pixel
		addi	$v0, $zero, 32			# 32 = sleep
		addiu   $a0, $zero, 30			# delay in ms
		syscall
		addi    $t6, $zero,  0x0000             # blck
		sw      $t6, 7544($t7)	                # store player in pixel
		add     $t7, $t7, 256			# move ptr left
		addi    $t3, $t3, -1			# i--
		j	inner_S
	
after_inner_S:
 	j DELAY_LOOP	 
 	
handleW:
	addiu    $t3, $zero, 5
	inner_W:
		beq     $t3, $zero, after_inner_W 
		addi    $t6, $zero, 0x00fff7           # teal
		sw      $t6, 7288($t7)	                # store player in pixel
		addi	$v0, $zero, 32			# 32 = sleep
		addiu   $a0, $zero, 30			# delay in ms
		syscall
		addi    $t6, $zero,   0x00000           # blk
		sw      $t6, 7544($t7)	                # store player in pixel
		add     $t7, $t7, -256			# move ptr left
		addi    $t3, $t3, -1			# i--
		j	inner_W
	
	
after_inner_W:
 	j DELAY_LOOP	 					
	
DELAY_LOOP:
	addi    $t2, $zero,0      # i=0
	slt     $t3, $t2,$t8      # i < LOOP_COUNT
	beq     $t3,$zero, DELAY_DONE

	addi    $t2, $t2,1        # i++
	j       DELAY_LOOP
	
DELAY_DONE:
	j       OUTER_LOOP
	
####################
# will control the player scenery
####################
playerbg:
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
    
  genRandom:
	# Divide 16384 by 4
	li $t0, 16384
	srl $t0, $t0, 2  # $t0 = 16384 / 4

	# Divide 256 by 4
	li $t1, 256
	srl $t1, $t1, 2  # $t1 = 256 / 4

	# Get the random value for x using syscall 42
	addi	$v0, $zero, 42	# random int 
	addi	$a1, $zero, 1000	# upper bound
	syscall
	add	$t2, $zero, $a0		# random X
	sll     $t2, $t2, 2   		# multiple by 4
	
	# Calculate the expression
	add $t3, $t0, $t1  # $t3 = (16384 / 4) + (256 / 4)
	add $t3, $t3, $t2  # $t3 = (16384 / 4) + (256 / 4) + x
	j afterRandom

afterRandom:
#3,4,5,6,7
	la      $t9, DISPLAY
	addi    $t1, $zero,  0xfc7f03         # orange
	sw   	$t1, 0($t9)
	add     $t9, $t9, $t3
	addi    $t9, $t9, -8
	addi    $t1, $zero,  0xc300ff        # purple
	sw   	$t1, 0($t9)
	addi    $t8, $zero, 1
 fg_inner:	
	beq  	$t8, $zero, AFTER_fg_inner
	sw   	$t1, 0($t9)
	addi    $t8, $t8, -1
	j fg_inner

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


lw $ra, 4($sp) # get return address from stack
lw $fp, 0($sp) # restore the caller�s frame pointer
addiu $sp, $sp, 52 # restore the caller�s stack pointer
jr $ra # return to caller�s code

background_TOP:
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
    	
bg_top_loop:
	
	la	$t0, DISPLAY
	addi	$t8, $zero, 1216
	addi    $t1, $zero,  0x14FF00         # green
	bg_top_inner:
		beq	$t8, $zero, AFTER_BG_TOP_INNER
		sw 	$t1, 0($t0)
		add	$t0, $t0, 4
		addi	$t8, $t8, -1
		j bg_top_inner
    
AFTER_BG_TOP_INNER:
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


lw $ra, 4($sp) # get return address from stack
lw $fp, 0($sp) # restore the caller�s frame pointer
addiu $sp, $sp, 52 # restore the caller�s stack pointer
jr $ra # return to caller�s code

background_BOTTOM:
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
    	
bg_bot_loop:
	
	la	$t0, DISPLAY
	addi	$t8, $zero, 1024
	addi    $t1, $zero,  0x223A3D         # greyish
	bg_bot_inner:
		beq	$t8, $zero, AFTER_BG_BOT_INNER
		sw 	$t1, 7424($t0)
		add	$t0, $t0, 4
		addi	$t8, $t8, -1
		j bg_bot_inner
    
AFTER_BG_BOT_INNER:
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

lw $ra, 4($sp) # get return address from stack
lw $fp, 0($sp) # restore the caller�s frame pointer
addiu $sp, $sp, 52 # restore the caller�s stack pointer
jr $ra # return to caller�s code
    
    
