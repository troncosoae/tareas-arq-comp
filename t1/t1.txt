.globl  start
.data
    # --- TERREMOTO ---
    I: .word 15, 84, 11	# porcentajes de cada uno de los ingredientes, siempre suman 100
    # No modificar
    Wa: .word 15, 48, 37 	# pesos w_a para el primer perceptron
    Wb: .word 4, 2, 8 	# pesos w_b para el segundo perceptron
    U:  .word 550	# umbral
    # --- END TERREMOTO ---
    # de aca para abajo van sus variables en memoria
.text
    start:
        # aca va su codigo  :3
            
            perc1:
            # perceptron 1
            la a2, I
            la a3, U
            la a4, Wa
            jal ra, perceptron
            mv t0, a0
            
            #j end
            
            perc2:
            # perceptron 2            
            la a2, I
            la a3, U
            la a4, Wb
            jal ra, perceptron
            mv t1, a0
            
            and a0, t0, t1
        
        j end
        
        perceptron:
            # A(sum(Wx))
            # registros de entrada son:
            #   I -> a2
            #   U -> a3
            #   Wa -> a4
            # registros de salida son:
            #   y -> a0
            # registros temporales son:
            #   t0, t1, t2, t3, t4, t5, t6
            
            addi sp, sp, -64
            sw ra, 0(sp)
            sw t0, 8(sp)
            sw t1, 16(sp)
            sw t2, 24(sp)
            sw t3, 32(sp)
            sw t4, 40(sp)
            sw t5, 48(sp)
            sw t6, 56(sp)
            
            #la t0, I
            lw t0, 0(a2) # I
            lw t1, 4(a2)
            lw t2, 8(a2)
            
            #la t1, U
            lw t3, 0(a3) # U
            
            #la t2, Wa
            lw t4, 0(a4) # Wi
            lw t5, 4(a4)
            lw t6, 8(a4)
            
            mul t0, t0, t4
            mul t1, t1, t5
            mul t2, t2, t6
            
            add t0, t0, t1
            add t0, t0, t2 # sum
            
            mv a2, t0
            mv a3, t3
            jal ra, activacion
            mv a0, a0
            
            end_perceptron:
            	lw ra, 0(sp)
                lw t0, 8(sp)
                lw t1, 16(sp)
                lw t2, 24(sp)
                lw t3, 32(sp)
                lw t4, 40(sp)
                lw t5, 48(sp)
                lw t6, 56(sp)
            	addi sp, sp, 64
                jalr zero, 0(ra)

        activacion:
            # y = f(x, u)
            # registros de entrada son:
            #   x -> a2
            #   u -> a3
            # registros de salida son:
            #   y -> a0
            # registros temporales son: 
            #   s0, s1, t0
            
            addi sp, sp, -32
            sw ra, 0(sp)
            sw s0, 8(sp)
            sw s1, 16(sp)
            sw t0, 24(sp)
            
            mv s0, a2
            mv s1, a3
            
            bgt s0, s1, activacion_if
                # x <= u
                addi a2, s0, -1
                mv a3, s0
                jal ra, module
                mv t0, a0
                
            j end_activacion_if
            activacion_if:
                # x > u
                li a2, 3
                mv a3, s0
                mv a4, s0
                jal ra, exp_module
                mv a2, a0
                li a3, 3
                jal ra, module
                mv t0, a0
            
            end_activacion_if:
            mv a2, t0
            jal ra, heaviside
            mv a0, a0
                        
            j end_activacion
            
            end_activacion:
            	lw ra, 0(sp)
                lw s0, 8(sp)
                lw s1, 16(sp)
                lw t0, 24(sp)
            	addi sp, sp, 32
                jalr zero, 0(ra)
        
        exp_module:
            # x = (a**b % c)
            # registros de entrada son: 
            #   a -> a0 a2
            #   b -> a1 a3
            #   c -> a2 a4
            # registros salida: 
            #   x -> a3 a0
            # registros temporales: 
            #   t0 -> 00001000 moving left
            #   t1 = 700
            #   t2 -> t0 & b
            #   t3 = prev % c
            
            addi sp, sp, -80
            sw ra, 0(sp)
            sw s0, 8(sp)
            sw s1, 16(sp)
            sw s2, 24(sp)
            sw t0, 32(sp)
            sw t1, 40(sp)
            sw t2, 48(sp)
            sw t3, 56(sp)
            sw t4, 64(sp)
            sw t5, 72(sp)
            
            mv s0, a2
            mv s1, a3
            mv s2, a4
            
            li t0, 1 # t0 = 000000...001
            li t1, 700
            li t2, 0
            
           
            # a % c
            mv a2, s0
            mv a3, s2
            jal ra, module
            mv t3, a0 # prev a**i % c
            
            and t2, t0, s1
            beq t2, zero, exp_module_else
            	mv t5, t3 # valor para ir guardando la multiplicacion
            	j exp_module_end_if
            exp_module_else:
            	li t5, 1
            exp_module_end_if:
            
            # shift t0
            slli, t0, t0, 1 # t0 = 000...0010
            
            while_exp_module:
            	bgt t0, t1, end_while_exp_module
            	and t2, t0, s1
            	
            	# a**2i % c
            	mul t4, t3, t3
            	mv a2, t4
            	mv a3, s2
            	jal ra, module
            	mv t3, a0
            	
            	beq t2, zero, while_exp_module_continue
            	    # if t2 > 0
            	    mul t5, t5, t3
            	    
            	    ble t5, s2, else_while_exp_module_continue
            	    # if t5 > s2 -> get mod
            	    	mv a2, t5
            	    	mv a3, s2
            	    	jal ra, module
            	    	mv t5, a0
            	    
            	    else_while_exp_module_continue:
            	    
            	while_exp_module_continue:
            	# continue...
            	
            	slli, t0, t0, 1
            	j while_exp_module
            	
            end_while_exp_module:
            mv a2, t5
            mv a3, s2
            jal ra, module
            
            mv a3, a0
        
            end_exp_module:
                lw ra, 0(sp)
                lw s0, 8(sp)
                lw s1, 16(sp)
                lw s2, 24(sp)
                lw t0, 32(sp)
                lw t1, 40(sp)
                lw t2, 48(sp)
                lw t3, 56(sp)
                lw t4, 64(sp)
                lw t5, 72(sp)
            	addi sp, sp, 80
                jalr zero, 0(ra)

        module:
            # z = x % y
            # registros de entrada son:
            #   x -> a0 a2
            #   y -> a1 a3
            # registros de salida son:
            #   z -> a2 a0
            # registros temporales son: 
            #   t0
            
            addi sp, sp, -16
            sw ra, 0(sp)
            sw t0, 8(sp)
            
            li t0, 0
            
            j while_module
            
            while_module:
            	bgt t0, a2, end_while_module
            	add t0, t0, a3
            	j while_module
            
            end_while_module:
            sub t0, t0, a3
            
            sub a0, a2, t0
            
            j end_module
            
            end_module:
            	lw ra, 0(sp)
            	lw t0, 8(sp)
            	addi sp, sp, 16
                jalr zero, 0(ra)

        heaviside:
            # H(x) = 0 if x <= 0 else 1
            # registros de entrada son:
            #   x -> a2
            # registros de salida son:
            #   x -> a0
            # registros temporales son: 
            # ...
            
            addi sp, sp, -8
            sw ra, 0(sp)       
            
            bgt a2, zero, positive # if a2 > zero then target
                li a0, 0
                j end_heaviside

            positive:  # x > 0
                li a0, 1
                j end_heaviside
            
            end_heaviside:
            	lw ra, 0(sp)
            	addi sp, sp, 8
                jalr zero, 0(ra)

    end: