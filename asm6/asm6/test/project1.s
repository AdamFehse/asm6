.data
	DISPLAY:		.space  	16384
   	bgcolor:        	.word   0xcefad0        # light green
# Assuming the random value is stored in $a0
# Define a buffer to store the hexadecimal representation
	hex_buffer: 		.space 9   # Allocate space for a 9-character string (8 characters for hexadecimal representation + null terminator)

.text
		la  $t0, DISPLAY
		addi    $t6, $zero, 0x00fff7            # teal
		sw      $t6, 7544($t0)	                # store player in pixel
		sw      $t6, 7796($t0)	                # store player in pixel
		sw      $t6, 7804($t0)	                # store player in pixel
		



jal generateRandomColor
background:
    la  $t0, DISPLAY
    addi $t8, $zero, 1
    bg_top_inner:
        beq $t8, $zero, END
        sw  $a0, 0($t0)    # Use the color stored in $a0

        add $t0, $t0, 4
        addi $t8, $t8, -1
        j bg_top_inner
END:
    jal generateRandomColor
    j background   # Repeat background loop

# Function to generate a random hex color
generateRandomColor:
    li $a1, 16777216       # Set $a1 to the max bound for a 24-bit color (2^24 = 16777216)
    li $v0, 42             # Generate a random number
    syscall
    move $t0, $a0          # Store the random number in $t0

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

    jr $ra                    # Return with the generated random color in $a0

    
