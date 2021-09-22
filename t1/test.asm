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
        # li a0, 2 # a0 = 2 
        # li a7, 4 # a7 = 4 
        # li a1, 3
        # add t0, a0, a7 # t0 = a0 + a7
        
        # la t0, I
        # lw a2, I
        
        # jal t0, function

        li a0, -1
        jal t0, heaviside

        li a0, 1
        jal t0, heaviside
        
        j end

        heaviside:
            # H(x) = 0 if x <= 0 else 1
            # registro de retorno:
            #   t0
            # registros de entrada son:
            #   x -> a0
            # registros de salida son:
            #   x -> a1
            # registros temporales son: 
            # ...
            bgt a0, zero, positive # if a0 > zero then target
                li a1, 0
                j end_heaviside

            positive:  # x > 0
                li a1, 1
                j end_heaviside
            
            end_heaviside:
                jalr t0
            

        
        function:
            # f(x,y) = x + y
            # registro de retorno: 
            #   t0
            # registros de entrada son:
            #   x -> a0
            #   y -> a1
            # registros de salida son:
            #   x -> a2
            # registros temporales son: 
            # ...
            
            add a2, a0, a1  # a2 = a0 + a1

            jalr t0

    
    end:

