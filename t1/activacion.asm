.globl  start
.data
.text

    start:
        # aca va su codigo  :3

        li a0, 7
        li a1, 45
        li a2, 4
        # jal ra, activacion
        jal ra, exp_module
        
        j end

        activacion:
            # y = f(x)
            # registros de entrada son:
            #   x -> a0
            # registros de salida son:
            #   y -> a1
            # registros temporales son: 
            #   t0, a1
            
            addi sp, sp, -8
            sw ra, 0(sp)
            
            mv t0, a0 # guardo valor de x en t0
            
            # (3**x % x) % 3 = (((3 % x)**x) % x ) % 3
            
            # --- mod
            # y1 = 3 mod x
            # a2 = a0 mod a1
            li a0, 3
            mv a1, t0
            jal ra, module
            # --- mod
            
            # --- mod
            # y2 = y1**x
            # a2 = a0**a1
            mv a0, a2
            mv a1, t0
            jal ra, exp
            # --- mod
            
            # --- mod
            # y3 = y2 mod x
            # a2 = a0 mod a1
            mv a0, a2
            mv a1, t0
            jal ra, module
            # --- mod
            
            # --- mod
            # y4 = y3 mod 3
            # a2 = a0 mod a1
            mv a0, a2
            li a1, 3
            jal ra, module
            # --- mod
            
            j end_activacion
            
            # --- exp
            # y = exp 3 x
            # a2 = a0**a1
            mv a1, a0
            li a0, 3            
            jal ra, exp
            # --- exp
            
            # --- mod
            # z = y mod x
            # a2 = a0 mod a1
            mv a0, a2
            mv a1, t0
            jal ra, module
            # --- mod
            
            # --- mod
            # f = z mod 3
            # a2 = a0 mod a1
            li t0, 3
            mv a0, a2
            mv a1, t0
            jal ra, module
            # --- mod
                        
            j end_activacion
            
            # --- heaviside
            # g = h(f)
            mv a0, a2
            jal ra, heaviside
            # --- heaviside
                        
            j end_activacion
            
            end_activacion:
            	lw ra, 0(sp)
            	addi sp, sp, 8
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
            
            addi sp, sp, -64
            sw ra, 0(sp)
            sw s0, 8(sp)
            sw s1, 16(sp)
            sw s2, 24(sp)
            sw t0, 32(sp)
            sw t1, 40(sp)
            sw t2, 48(sp)
            sw t3, 56(sp)
            
            mv s0, a0
            mv s1, a1
            mv s2, a2
            
            li t0, 1
            li t1, 700
            li t2, 0
            
            # a % c
            mv a1, a2
            jal ra, module
            mv t3, a2
            
            while_exp_module:
            	bgt t0, t1, end_while_exp_module
            	and t2, t0, s1
            	
            	beq t2, zero, while_exp_module_continue
            	    # if t2 > 0
            	    
            	while_exp_module_continue:
            	# continue...
            	
            	slli, t0, t0, 1
            	j while_exp_module
            	
            end_while_exp_module:
        
            end_exp_module:
                lw ra, 0(sp)
                lw s0, 8(sp)
                lw s1, 16(sp)
                lw s2, 24(sp)
                lw t0, 32(sp)
                lw t1, 40(sp)
                lw t2, 48(sp)
                lw t3, 56(sp)
            	addi sp, sp, 64
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

