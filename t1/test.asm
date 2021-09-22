.globl  start
.data
    # --- TERREMOTO ---
    I: .word 5, 5, 90 	# porcentajes de cada uno de los ingredientes, siempre suman 100
    # No modificar
    Wa: .word 7, 3, 2 	# pesos w_a para el primer perceptron
    Wb: .word 4, 2, 8 	# pesos w_b para el segundo perceptron
    U:  .word 150 		# umbral
    # --- END TERREMOTO ---
    # de aca para abajo van sus variables en memoria
.text

    start:
        # aca va su codigo  :3

        li a0, -1
        jal ra, heaviside

        li a0, 1
        jal ra, heaviside
        
        jal ra, activacion
        
        j end

        heaviside:
            # H(x) = 0 if x <= 0 else 1
            # registros de entrada son:
            #   x       -> a0
            # registros de salida son:
            #   H(x)    -> a1
            # registros temporales son: 
            # ...
            bgt a0, zero, positive # if a0 > zero then target
                li a1, 0
                j end_heaviside

            positive:  # x > 0
                li a1, 1
                j end_heaviside
            
            end_heaviside:
                jalr zero, 0(ra)
        
        activacion:
            # A(x) = ...
            # registros de entrada son:
            #   x       -> a0
            # registros de salida son:
            #   A(x)    -> a1
            # registros temporales son: 
            # ...

            la s1, I
            lw t1, 0(s1) # t1 = H
            lw t2, 4(s1) # t2 = P
            lw t3, 8(s1) # t3 = G

            mul a1, t1, t2
            j end_activacion
        
            end_activacion:
                jalr zero, 0(ra)
    
    end:

