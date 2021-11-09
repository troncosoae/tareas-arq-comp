.globl start
.data
	str1: .asciz "Ingrese un tiempo: \n"
	str2: .asciz "Han pasado "
	str3: .asciz " segundos!\n"
	
	time_now_dir: .word 0xFFFF0018
	time_cmp_dir: .word 0xFFFF0020
	
.text
	start:
		# codigo
		
		jal ra, get_time
		mv s2, a0
		
		jal ra, start_timer
            	
            	j end
	
	get_time:
	    	# pide tiempo por consola
            	# registros de entrada son:
            	# registros de salida son:
            	#   a0 -> tiempo
            	# registros temporales son:
            	#   a7
            	addi sp, sp, -16
            	sw ra, 0(sp)
            	sw a7, 8(sp)
            	
            	# print Ingrese un tiempo:"
            	li a7, 4
            	la a0, str1
            	ecall
            	
            	# leer input"
            	li a7, 5
            	ecall
            	
            	end_get_time:
            	lw ra, 0(sp)
            	lw a7, 8(sp)
            	addi sp, sp, 16
                jalr zero, 0(ra)
        
        start_timer:
	    	# pide tiempo por consola
            	# registros de entrada son:
            	#   
            	# registros de salida son:
            	#
            	# registros temporales son:
            	#   a0, t0, t1, t2
            	addi sp, sp, -40
            	sw ra, 0(sp)
            	sw a0, 8(sp)
            	sw t0, 16(sp)
            	sw t1, 24(sp)
            	sw t2, 32(sp)
  	
  		# Set the handler address and enable interrupts
		la	t0, handler
		csrrs	zero, 5, t0
		csrrsi	zero, 4, 0x10
		csrrsi	zero, 0, 0x1
		
		li t1, 1000
		mul t1, t1, s2 # t1 = s2 * 1000
	
		# Set cmp to time
		lw a0 time_now_dir
		lw t2 0(a0)
		add t1 t2 t1
		lw t0 time_cmp_dir
		sw t1 0(t0)
		
		loop:

        		# Sleep for 10 ms
			li a0, 10
			li a7, 32
			ecall

			j	loop
		
		end_start_timer:
            	lw ra, 0(sp)
            	lw a0, 8(sp)
            	lw t0, 16(sp)
            	lw t1, 24(sp)
            	lw t2, 32(sp)
            	addi sp, sp, 40
                jalr zero, 0(ra)
	
	handler:
		# Save some space for temporaries
		addi	sp, sp, -20
		sw	t0, 16(sp)
		sw	t1, 12(sp)
		sw	t2, 8(sp)
		sw	a0, 4(sp)
		sw	a7, 0(sp)
            	
            	# print "Han pasado "
            	li a7, 4
            	la a0, str2
            	ecall
            
            	# print x (segundos)
            	li a7, 1
            	mv a0, s2
            	ecall
            	
            	# print " segundos!"
            	li a7, 4
            	la a0, str3
            	ecall
		
		jal ra, get_time
		mv s2, a0 # guardar tiempo en s2
		
		bgtz s2, skip_close
			# tiempo <= 0
			li a7, 10
			ecall
		
		skip_close:
		
		li t1, 1000
		mul t1, t1, s2 # t1 = s2 * 1000
	
		# Set cmp to time + 5000
		lw a0 time_now_dir
		lw t2 0(a0)
		add t1 t2 t1
		lw t0 time_cmp_dir
		sw t1 0(t0)
	
		# Reload the saved registers and return
		lw	t0, 16(sp)
		lw	t1, 12(sp)
		lw	t2, 8(sp)
		lw	a0, 4(sp)
		lw	a7, 0(sp)
		addi	sp, sp, 20	
		uret
	
	end:
            	
		
