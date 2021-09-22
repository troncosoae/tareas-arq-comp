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
        li a0, 2 # a0 = 2 
        li a7, 4 # a7 = 4 
        add t0, a0, a7 # t0 = a0 + a7
        
        la t0, I
        lw a2, I
