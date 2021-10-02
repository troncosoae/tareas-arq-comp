.globl  start
.data
    # --- TERREMOTO ---
    I: .word 15, 48, 37	# porcentajes de cada uno de los ingredientes, siempre suman 100
    # No modificar
    Wa: .word 7, 3, 2 	# pesos w_a para el primer perceptron
    Wb: .word 4, 2, 8 	# pesos w_b para el segundo perceptron
    U:  .word 550 		# umbral
    # --- END TERREMOTO ---
    # de aca para abajo van sus variables en memoria
.text
    start:
        # aca va su codigo  :3
        
            
            la t0, I
            lw a0, 0(t0)
            lw a1, 4(t0)
            lw a2, 8(t0)
            
            la t1, U
            lw t1, 0(t1)
            
            #j perc2
            
            perc1:
            # perceptron 1
            lw a0, 0(t0)
            lw a1, 4(t0)
            lw a2, 8(t0)
            la t2, Wa
            lw t3, 0(t2)
            lw t4, 4(t2)
            lw t5, 8(t2)
            
            mul t3, t3, a0
            mul t4, t4, a1
            mul t5, t5, a2
            
            add t3, t3, t4
            add t3, t3, t5
            
            mv a0, t3
            mv a1, t1
            jal ra, activacion
            mv t6, a2
            
            #j end
            
            perc2:
            # perceptron 2
            lw a0, 0(t0)
            lw a1, 4(t0)
            lw a2, 8(t0)
            la t2, Wb
            lw t3, 0(t2)
            lw t4, 4(t2)
            lw t5, 8(t2)
            
            mul t3, t3, a0
            mul t4, t4, a1
            mul t5, t5, a2
            
            add t3, t3, t4
            add t3, t3, t5
            
            mv a0, t3
            mv a1, t1
            jal ra, activacion
            mv s0, a2
            
            #j end
            
            and a0, s0, t6

        #li a0, 695
        #li a1, 500
        # li a1, 695
        # li a2, 695
        #jal ra, activacion
        # jal ra, exp_module
        
        j end
        
        perceptron:
            # A(sum(Wx))
            # registros de entrada son:
            #   I -> a0
            #   U -> a1
            #   Wa -> a2
            # registros de salida son:
            #   y -> a3
            # registros temporales son:
            #   ...
            
            end_perceptron:
            

        activacion:
            # y = f(x, u)
            # registros de entrada son:
            #   x -> a0
            #   u -> a1
            # registros de salida son:
            #   y -> a2
            # registros temporales son: 
            #   s0, s1, t0
            
            addi sp, sp, -32
            sw ra, 0(sp)
            sw s0, 8(sp)
            sw s1, 16(sp)
            sw t0, 24(sp)
            
            mv s0, a0
            mv s1, a1
            
            bgt s0, s1, activacion_if
                # x <= u
                addi a0, s0, -1
                mv a1, s0
                jal ra, module
                mv t0, a2
                
            j end_activacion_if
            activacion_if:
                # x > u
                li a0, 3
                mv a1, s0
                mv a2, s0
                jal ra, exp_module
                mv a0, a3
                li a1, 3
                jal ra, module
                mv t0, a2
            
            end_activacion_if:
            mv a0, t0
            jal ra, heaviside
            mv a2, a1
                        
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
            #   a -> a0
            #   b -> a1
            #   c -> a2
            # registros salida: 
            #   x -> a3
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
            
            mv s0, a0
            mv s1, a1
            mv s2, a2
            
            li t0, 1 # t0 = 000000...001
            li t1, 700
            li t2, 0
            
           
            # a % c
            mv a1, s2
            jal ra, module
            mv t3, a2 # prev a**i % c
            
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
            	mv a0, t4
            	mv a1, s2
            	jal ra, module
            	mv t3, a2
            	
            	beq t2, zero, while_exp_module_continue
            	    # if t2 > 0
            	    mul t5, t5, t3
            	    
            	    ble t5, s2, else_while_exp_module_continue
            	    # if t5 > s2 -> get mod
            	    	mv a0, t5
            	    	mv a1, s2
            	    	jal ra, module
            	    	mv t5, a2
            	    
            	    else_while_exp_module_continue:
            	    
            	while_exp_module_continue:
            	# continue...
            	
            	slli, t0, t0, 1
            	j while_exp_module
            	
            end_while_exp_module:
            mv a0, t5
            mv a1, s2
            jal ra, module
            
            mv a3, a2
        
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
            #   x -> a0
            #   y -> a1
            # registros de salida son:
            #   z -> a2
            # registros temporales son: 
            #   t0
            
            addi sp, sp, -16
            sw ra, 0(sp)
            sw t0, 8(sp)
            
            li t0, 0
            
            j while_module
            
            while_module:
            	bgt t0, a0, end_while_module
            	add t0, t0, a1
            	j while_module
            
            end_while_module:
            sub t0, t0, a1
            
            sub a2, a0, t0
            
            j end_module
            
            end_module:
            	lw ra, 0(sp)
            	lw t0, 8(sp)
            	addi sp, sp, 16
                jalr zero, 0(ra)

        heaviside:
            # H(x) = 0 if x <= 0 else 1
            # registros de entrada son:
            #   x -> a0
            # registros de salida son:
            #   x -> a1
            # registros temporales son: 
            # ...
            
            addi sp, sp, -8
            sw ra, 0(sp)       
            
            bgt a0, zero, positive # if a0 > zero then target
                li a1, 0
                j end_heaviside

            positive:  # x > 0
                li a1, 1
                j end_heaviside
            
            end_heaviside:
            	lw ra, 0(sp)
            	addi sp, sp, 8
                jalr zero, 0(ra)

        exp:
            # z = x**y
            # registros de entrada son:
            #   x -> a0
            #   y -> a1
            # registros de salida son:
            #   z -> a2
            # registros temporales son: 
            #   t0, t1
            
            addi sp, sp, -24
            sw ra, 0(sp)
            sw t0, 8(sp)
            sw t1, 16(sp)
            
            addi a2, a0, 0
            addi t0, a1, 0
            li t1, 1
            sub t0, t0, t1
            
            j while_exp
            
            while_exp:
            	beq t0, zero, end_while_exp
            	sub t0, t0, t1
            	mul a2, a2, a0
            	j while_exp
            
            end_while_exp:
            
            j end_exp
            
            end_exp:
            	lw ra, 0(sp)
            	lw t0, 8(sp)
            	lw t1, 16(sp)
            	addi sp, sp, 24
                jalr zero, 0(ra)

    end:


        
