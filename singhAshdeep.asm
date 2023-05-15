.data
frameBuffer: .space 0x80000 # 512 wide X 256 high pixels
m: .word 100 #inner box dimensions
n: .word 200 #outer box dimensions
c1r: .word 0xFF # color for inner 
c1g: .word 0x00
c1b: .word 0x00
c2r: .word 0x00 # color for outer
c2g: .word 0xFF
c2b: .word 0x00

.text
drawLine: 
	  addi $s1, $zero, 512 # $s1 <- 512 
	  addi $s2, $zero, 256 # $s2 <- 256 
	  lw $s3, n # $s3 <- n (outer) 
	  lw $s4, m # $s4 <- m (inner) 
	  
	  #yellow background
	  la $t0,frameBuffer # $t0 <- addr of frameBuffer 
	  li $t1, 0x20000 # $t1 <- 0x20000 (512*256)
	  li $t2, 0x00FFFF00 # $t2 <- 0x00FFFF00 (yellow)
	  l1: sw $t2, 0($t0) # $t0 <- $t2 
	  addi $t0, $t0, 4 # $t0 = $t0 + 4
	  addi $t1, $t1, -1 # $t1 = $t1 - 1
	  bne $t1, $zero, l1 #if $t1 does not equal 0, branch to l1
	  
	  #Edge cases 
	  slt $t2, $s2, $s3 # t2 <- 1 if $s2 < $s3 (end if n > 256)
	  bne $t2, $zero, End #if t2 does not equal 0, go to End
	  slt $t2, $s2, $s4 # t2 <- 1 if $s2 < $s4 (end if m > 256)
	  bne $t2, $zero, End #if t2 does not equal 0, go to End
	  slt $t2, $s3, $s4 # t2 <- 1 if $s3 < $s4 (end if  m > n)
	  bne $t2, $zero, End #if t2 does not equal 0, go to End
	  andi $t2, $s3, 0x001 # t2<- 1 if $s3 is odd (end if n is odd)
	  bne $t2, $zero, End # if t2 does not equal 0, go to End
	  andi $t2, $s4, 0x001 # t2<- 1 if $s4 is odd (end if m is odd)
	  bne $t2, $zero, End # if t2 does not equal 0, go to End
	  beq $s3, $s4, End # if $s3 = $s4, go to End
	  beq $s3, $zero, End # if $s3 = 0, go to End
	  beq $s4, $zero, End #if $s4 = 0, go to End
	  slt $t2, $s3, $zero # $t2 <- 1 if $s3 < $zero (n < 0)
	  bne $t2, $zero, End # if t2 does not equal 0, go to End
	  slt $t2, $s4, $zero # $t2 <- 1 if $s4 < $zero (m < 0)
	  bne $t2, $zero, End # if t2 does not equal 0, go to End
	  
	  #set color for outer box:
	  lw $t1, c2r # $t1 <- c2r
	  lw $t2, c2g # $t2 <- c2g
	  lw $t3, c2b # $t3 <- c2b
	  sll $t1, $t1, 16 # $t1 <- $t1 shifted by 16 bits
	  sll $t2, $t2, 8 # $t2 <- $t2 shifted by 8 bits
	  add $t2, $t1, $t2 # $t2 = $t2 + $t1
	  add $t2, $t2, $t3 # $t2 = $t2 + $t3
	  
	  #calculations for outer box:
	  srl $t4, $s1, 1 # $t4 <- $s1 shifted 1 bit to the right (512/2)
	  srl $t5, $s2, 1 # $t5 <- $s2 shifted 1 bit to the right (256/2)
	  srl $t6, $s3, 1 # $t6 <- $s3 shifted 1 bit to the right (n/2)
	  sub $t4, $t4, $t6 # $t4 <- $t4 + $t6 (512/2) - (n/2)
	  sub $t5, $t5, $t6 # $t5 <- $t5 + $t6 (256/2) - (n/2)
	  
	  #calculate rows to skip for outer box:
	  add $t3, $zero, $t5 # $t3 <- $t5 ((256/2) - (n/2))
	  add $t1, $zero, $zero # $t1 = 0
	  loopSkip: addi $t1, $t1, 2048 # $t1 = $t1 + 2048 (skip top rows)
	  addi $t3, $t3, -1 # $t3 = $t3 - 1 
	  bne $t3, $zero, loopSkip # if $t3 does not = 0, go to loopSkip
	  sll $t4, $t4, 2 # $t4 = $t2 shifted 2 bits to the left ((512/2) - (n/2)) * 4
	  add $t1, $t1, $t4 # $t1 = $t1 + $t4 (pixels skipped in total)
	  
	  #Draw Outer Box:
	  la $t0,frameBuffer # $t0 <- addr of frameBuffer (reset position)
	  add $t0, $t0, $t1 # $t0 <- $t0 + $t1 (skip pixels) 
	  add $t3, $zero, $s3 # $t3 = $s3 (counter)
	  loop2:
	  add $t1, $zero, $s3 # $t1 <- $s3 (counter) 
	  loop1: sw $t2, 0($t0) # $t0 <- $t2 (store color)
	  addi $t0, $t0, 4 # $t0 = $t0 + 4
	  addi $t1, $t1, -1 # $t1 = $t1 - 1
	  bne $t1, $zero, loop1 # if $t1 does not equal 0 go to loop1 (fill row)
	  sll $t7, $t4, 1 #  $t7 <- $t4 shifted 1 bit to the left (t4*2)
	  add $t0, $t0, $t7 # $t0 = $t0 + $t7 (skip pixels)
	  add $t3, $t3, -1 # $t3 = $t3 - 1
	  bne $t3, $zero, loop2	 # if $t3 does not equal 0, go to loop2 (fill box)
	  
	  # DIAGONAL 1 Calculations:
	  srl $t4, $s1, 1 # $t4 <- $s1 shifted 1 bit to the right (512/2)
	  srl $t5, $s2, 1 # $t5 <- $s2 shifted 1 bit to the right (256/2)
	  srl $t6, $s3, 1 # $t6 <- $s3 shifted 1 bit to the right (n/2)
	  sub $t4, $t4, $t6 # $t4 <- $t4 - $t6 (512/2) - (n/2)
	  sub $t5, $t5, $t6 # $t5 <- $t5 - $t6 (256/2) - (n/2)
	  
	  # DIAGONAL 1 pixels to skip:
	  addi $t2, $zero, 0x00000000 # $t2 <- 0x00 (set to black)
	  add $t3, $zero, $t5 # $t3 <- $t5 ((256/2) - (n/2))
	  add $t1, $zero, $zero # $t1 <- 0
	  loopSkip66: addi $t1, $t1, 2048 # $t1 = $t1 + 2048 (skip row)
	  addi $t3, $t3, -1 # $t3 = $t3 - 1
	  bne $t3, $zero, loopSkip66 # if $t3 does not equal = 0 go to loopSkip66
	  sll $t4, $t4, 2 # $t4 = $t4 shifted to 2 bits to the left ((512/2) - (n/2)) * 4
	  add $t1, $t1, $t4 # $t1 = $t1 + $t4 (rows skipped)
	  
	  # Draw DIAGONAL 1:
	  la $t0,frameBuffer # $t0 <- addr of frameBuffer (reset position)
	  add $t0, $t0, $t1 # $t0 = $t0 + $t1 #skip pixels
	  add $t1, $zero, $s3 # $t1 <- $s3 (counter)
	  loop66: sw $t2, 0($t0) # $t0 <- $t2 (store black)
	  addi $t0, $t0, 2052 # $t0 = $t0 + 2052
	  addi $t1, $t1, -1 # $t1 = $t1 - 1
	  bne $t1, $zero, loop66 # if $t1 does not equal 0, go to loop66
	  
	  # DIAGONAL 2 Calculations:
	  srl $t4, $s1, 1 # $t4 <- $s1 shifted 1 bit to the right (512/2)
	  srl $t5, $s2, 1 # $t5 <- $s2 shifted 1 bit to the right (256/2)
	  srl $t6, $s3, 1 # $t6 <- $s3 shifted 1 bit to the right (n/2)
	  sub $t4, $t4, $t6 # $t4 <- $t4 - $t6 (512/2) - (n/2)
	  sub $t5, $t5, $t6 # $t5 <- $t5 - $t6 (256/2) - (n/2)
	  
	  # DIAGONAL 2 pixels to skip:
	  addi $t2, $zero, 0x00000000 # $t2 <- 0x00
	  add $t3, $zero, $t5 #  $t3 <- $t5 ((256/2) - (n/2))
	  add $t1, $zero, $zero # $t1 <- 0
	  loopSkip76: addi $t1, $t1, 2048 # $t1 = $t1 + 2048 (skip row)
	  addi $t3, $t3, -1 # $t3 = $t3 - 1
	  bne $t3, $zero, loopSkip76 # if $t3 does not = 0, go to loopSkip
	  sll $t4, $t4, 2 # $t4 = $t4 shifted to 2 bits to the left ((512/2) - (n/2)) * 4
	  sll $t6, $s3, 2 # $t6 = $s3 shifted 2 bits to the left (n/2*4)
	  add $t1, $t1, $t4 # $t1 = $t1 + $t4 (rows skipped)
	  add $t1, $t1, $t6 # $t1 = $t1 + $t6 (end of box)
	  
	  # Draw DIAGONAL 2:
	  la $t0,frameBuffer # $t0 <- addr of frameBuffer (reset position)
	  add $t0, $t0, $t1 # $t0 = $t0 + $t1
	  addi $t0, $t0, -4 # $t0 <- $t0 - 4
	  add $t1, $zero, $s3 # $t1 <- $s3 (counter)
	  loop76: sw $t2, 0($t0) # $t0 <- $t2 (store black)
	  addi $t0, $t0, 2044 # $t0 = $t0 + 2044
	  addi $t1, $t1, -1 # $t1 = $t1 - 1
	  bne $t1, $zero, loop76 # if $t1 does not equal 0, go to loop76
	  
	  #Set color for inner box:
	  lw $t1, c1r # $t1 <- c1r
	  lw $t2, c1g # $t1 <- c1g
	  lw $t3, c1b # $t1 <- c1b
	  sll $t1, $t1, 16 # $t1 <- $t1 shifted by 16 bits
	  sll $t2, $t2, 8 # $t2 <- $t2 shifted by 8 bits
	  add $t2, $t1, $t2 # $t2 = $t2 + t1
	  add $t2, $t2, $t3 # $t2 = $t2 + t3
	  
	  #calculations for inner box:
	  srl $t4, $s1, 1 # $t4 <- $s1 shifted 1 bit to the right (512/2)
	  srl $t5, $s2, 1 # $t5 <- $s2 shifted 1 bit to the right (256/2)
	  srl $t6, $s4, 1 # $t6 <- $s4 shifted 1 bit to the right (m/2)
	  sub $t4, $t4, $t6 # $t4 <- #t4 - $t6 (512/2) - (m/2)
	  sub $t5, $t5, $t6 # $t5 <- #t5 - $t6 (256/2) - (m/2)
	  
	  #calculate rows to skip for inner box:
	  add $t3, $zero, $t5 # $t3 <- $t5 ((256/2) - (m/2))
	  add $t1, $zero, $zero # $t1 <- 0
	  loopSkip2: addi $t1, $t1, 2048 # $t1 = $t1 + 2048 (skip row)
	  addi $t3, $t3, -1 # $t3 = $t3 - 1
	  bne $t3, $zero, loopSkip2 # if $t3 does not = 0, go to loopSkip
	  sll $t4, $t4, 2 # $t4 = $t4 shifted 2 bits to the left (((512/2) - (m/2)) * 4)
	  add $t1, $t1, $t4 # $t1 = $t1 + $t4 (rows skipped)
	  
	  #Draw Inner Box:
	  la $t0,frameBuffer # $t0 <- addr of frameBuffer (reset pos)
	  add $t0, $t0, $t1 # $t0 = $t0 + $t1 (skip pixels) 
	  add $t3, $zero, $s4 # $t3 = $s4 (counter)
	  loop4:
	  add $t1, $zero, $s4 # $t1 = $s4 (counter) 
	  loop3: sw $t2, 0($t0) # $t0 <- $t2 (store color)
	  addi $t0, $t0, 4 # $t0 = $t0 + 4
	  addi $t1, $t1, -1 # $t1 = $t1 - 1
	  bne $t1, $zero, loop3 # if $t1 does not = 0, go to loop 3 (fill row)
	  sll $t7, $t4, 1 # $t7 = $t4 shifted 1 bit to the left (t4*2)
	  add $t0, $t0, $t7 # $t0 = $t0 + $t7 (skip pixels)
	  add $t3, $t3, -1 #$t3 = $t3 - 1
	  bne $t3, $zero, loop4	 # if $t3 does not equal 0, go to loop 4 (fill box)
	  
	  #END:
	  End:
	  li $v0,10 # exit code
	  syscall # exit to OS
	  
	  
	  
	  
	  
	  
