.globl  start
.data
    # --- TERREMOTO ---
    I: .word H, P, G 	# porcentajes de cada uno de los ingredientes, siempre suman 100
    # No modificar
    Wa: .word 7, 3, 2 	# pesos w_a para el primer perceptron
    Wb: .word 4, 2, 8 	# pesos w_b para el segundo perceptron
    U:  .word 150 		# umbral
    # --- END TERREMOTO ---
    # de aca para abajo van sus variables en memoria
.text
    start:
        # aca va su codigo  :3