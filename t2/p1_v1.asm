.globl start
.data
	N: .word 3  # cant personas
	amigues: .word 0, 1, 2  # ID pp
	G: .word 3 # No gastos
	gastos: .float 0.0, 3000.0, 2.0, 0.0, 1.0, 1.0, 5000.0, 1.0, 2.0, 1.0, 1000.0, -1.0
	
	#N: .word 5
	#amigues: .word 0, 1, 2, 3, 4
	#G: .word 5
	#gastos: .float 0.0, 1000.0, -1.0,2.0, 2000.0, 2.0, 1.0, 2.0, 3.0, 5000.0, -1.0, 4.0, 20000.0, 4.0, 0.0, 2.0, 3.0, 4.0, 3.0, 20000.0, 4.0, 0.0, 2.0, 3.0, 4.0
	
	#N: .word 7
	#amigues: .word 0, 1, 2, 3, 4, 5, 6
	#G: .word 8
	#gastos: .float 6.0, 1000.0, -1.0, 4.0, 15000.0, 3.0, 0.0, 2.0, 3.0, 3.0, 2000.0, -1.0, 6.0, 2700.0, 4.0, 0.0, 1.0, 3.0, 4.0, 2.0, 200.0, 2.0, 0.0, 2.0, 6.0, 700.0, 2.0, 0.0, 5.0, 2.0, 1250.0, 1.0, 0.0, 4.0 5000.0 -1.0
	
	#N: .word  3
	#amigues: .word 0, 1, 2
	#G: .word 3
	#gastos: .float 0.0, 30000.9, -1.0, 1.0, 15500.0, -1.0, 2.0, 2370.0, -1.0
	# ID_pagador, monto, n_involucrados, ID_invol1, ID_invol2, ..., ID_invon
	
	print_strings: .asciz "debe a\n"
	print_strings2: .asciz "\n"
	
	
.text
	start:
		j start2
		
		start2:
		li s1, 0x10000000 # primera direccion de extern
		
		# generar arreglo de datos
		mv a2, s1 # dir arreglo
		la a3, N # dir N
		la a4, amigues # dir ids
		jal ra, crear_arreglo_gastos
		
		# cargar gastos
		la a2, gastos # direccion gastos
		mv a3, s1 # direccion arreglo
		la a4, G # dir G
		jal ra, cargar_gastos_todos
		
		# print_gastos
		mv a2, s1 # dir arreglo
		la a3, print_strings
		la a4, print_strings2
		jal ra, print_gastos
		
		j end_all		
	    
	
	print_gastos:
	    # para imprimir gastos por persona
            # registros de entrada son:
            #   dir_arreglo -> a2
            #   dir_print_strings -> a3
            #   dir_print_strings -> a4
            # registros de salida son:
            #   
            # registros temporales son:
            #  a7, t1, t2, ft1, ft2, ft3, t4, ft0, ft4
            #  t5 -> dir_arreglo
            #  t3 -> dir_print_strings
            #  t6 -> dir_print_strings2
            addi sp, sp, -96
            sw ra, 0(sp)
            sw a7, 8(sp)
            sw t1, 16(sp)
            sw t2, 24(sp)
            sw t3, 32(sp)
            sw t4, 40(sp)
            sw t5, 48(sp)
            fsw ft0, 48(sp)
            fsw ft1, 56(sp)
            fsw ft2, 64(sp)
            fsw ft3, 72(sp)
            fsw ft4, 80(sp)
            sw t6, 88(sp)
            
            mv t5, a2
            
            #lw t0, 0(a2) # N (int)
            #flw ft0, 4(a2) # N (float)
            mv t1, a3 # dir "debe a"
            mv t6, a4
            
            fcvt.w.s zero, ft3 # ft3 = 0.0
            li t4, 1 # t4 = 1
            
            mv a2, a2
            jal ra, buscar_mayor_deudor_pagador
            flw ft1, 4(a0) # deuda mayor
            flw ft2, 4(a1) # pago mayor
            
            while_print_gastos:
            	feq.s t3, ft1, ft3 # verficiar si las deudas son todas 0
            	beq t4, t3, end_while_print_gastos
            	feq.s t3, ft2, ft3 # verficiar si las deudas son todas 0
            	beq t4, t3, end_while_print_gastos
            	
            	# sacar la suma de ambas (positivo -> mayor deuda; negativo o cero -> mayor pago)
            	fadd.s ft0, ft1, ft2
            	fle.s t3, ft0, ft3 # t3 = 1 if ft0 <= 0
            	beq t4, t3, if_nz_while_print_gasto
            	if_p_while_print_gasto:
            	# si es pos: sumar a deudor valor del pagador
            	#            deudor debe (pagado) a pagador
            	    # saldar en memoria
            	    fsw ft0, 4(a0)
            	    fsw ft3, 4(a1)
            	    # imprimir saldado
            	    feq.s t3, ft1, ft3 # verficiar si las deudas son todas 0
            	    beq t4, t3, skip_print_gastos1
            	    feq.s t3, ft2, ft3 # verficiar si las deudas son todas 0
            	    beq t4, t3, skip_print_gastos1
            	    lw a2, 0(a0)
            	    lw a3, 0(a1)
            	    li t2, -1
            	    fcvt.s.w ft4, t2
            	    fmul.s fa2, ft2, ft4
            	    mv a4, t1
            	    mv a5, t6
            	    jal ra, print_saldo
            	    skip_print_gastos1:
            	    
            	    j end_if_while_print_gasto
            	if_nz_while_print_gasto:
            	# si es neg o cero: restar al pagador valor de deudor
            	#            deudor debe (deuda) a pagador
            	    # saldar en memoria
            	    fsw ft3, 4(a0)
            	    fsw ft0, 4(a1)
            	    # imprimir saldado
            	    feq.s t3, ft1, ft3 # verficiar si las deudas son todas 0
            	    beq t4, t3, skip_print_gastos2
            	    feq.s t3, ft2, ft3 # verficiar si las deudas son todas 0
            	    beq t4, t3, skip_print_gastos2
            	    lw a2, 0(a0)
            	    lw a3, 0(a1)
            	    fmv.s fa2, ft1
            	    mv a4, t1
            	    mv a5, t6
            	    jal ra, print_saldo
            	    skip_print_gastos2:
            	    
            	    j end_if_while_print_gasto
            	end_if_while_print_gasto:
            	
            	mv a2, t5
            	mv a3, t1
                jal ra, buscar_mayor_deudor_pagador
                flw ft1, 4(a0) # deuda mayor
                flw ft2, 4(a1) # pago mayor
            	
            	j while_print_gastos
            end_while_print_gastos:
            
            end_print_gastos:
            	lw ra, 0(sp)
            	lw ra, 0(sp)
            	lw a7, 8(sp)
            	lw t1, 16(sp)
            	lw t2, 24(sp)
            	lw t3, 32(sp)
            	lw t4, 40(sp)
            	lw t5, 48(sp)
            	flw ft0, 48(sp)
            	flw ft1, 56(sp)
            	flw ft2, 64(sp)
            	flw ft3, 72(sp)
            	flw ft4, 80(sp)
            	lw t6, 88(sp)
            	addi sp, sp, 96
                jalr zero, 0(ra)
        
        print_saldo:
            # para imprimir un saldo en particular
            # registros de entrada son:
            #   id_deudor -> a2
            #   id_pagador -> a3
            #   monto -> fa2
            #   dir_print_strings -> a4
            #   dir_print_strings -> a5
            # registros de salida son:
            #   
            # registros temporales son:
            #  a7, t1, t2
            addi sp, sp, -32
            sw ra, 0(sp)
            sw a7, 8(sp)
            sw t1, 16(sp)
            sw t2, 24(sp)

            mv t1, a4 # dir "debe a"
            mv t2, a5
            #addi t2, t1, 16 # dir "\n"
            
            # id_deudor
            li a7, 1
            mv a0, a2
            ecall
            
            # print "\n"
            li a7, 4
            mv a0, t2
            ecall
            
            # print "debe a"
            li a7, 4
            mv a0, t1
            ecall
            
            # id_pagador
            li a7, 1
            mv a0, a3
            ecall
            
            # print "\n"
            li a7, 4
            mv a0, t2
            ecall
            
            # print N (float)
            li a7, 2
            fmv.s fa0, fa2
            ecall
            
            # print "\n"
            li a7, 4
            mv a0, t2
            ecall
            
            end_print_saldo:
            	lw ra, 0(sp)
                lw a7, 8(sp)
                lw t1, 16(sp)
                lw t2, 24(sp)
            	addi sp, sp, 32
                jalr zero, 0(ra)
	
	buscar_mayor_deudor_pagador:
	    # para buscar al mayor deudor
            # registros de entrada son:
            #   dir_arreglo -> a2
            # registros de salida son:
            #   dir_duedor_mayor -> a0
            #   dir_pagador_mayor -> a1
            # registros temporales son:
            #   t0 -> N, counter
            #   t1 -> dir deudor mayor
            #   ft1 -> deuda deudor mayor
            #   t4 -> dir pagador mayor
            #   ft4-> deuda pagador mayor
            #   t2 -> dir deudor_i
            #   ft2 -> deuda deudor_i
            #   t3
            addi sp, sp, -72
            sw ra, 0(sp)
            sw t0, 8(sp)
            sw t1, 16(sp)
            fsw ft1, 24(sp)
            sw t2, 32(sp)
            fsw ft2, 40(sp)
            sw t3, 48(sp)
            sw t4, 56(sp)
            fsw ft4, 64(sp)
            
            lw t0, 0(a2) # N (int)
            addi t1, a2, 12 # dir deudor mayor
            flw ft1, 4(t1) # deuda mayor
            addi t4, a2, 12 # dir pagador mayor
            flw ft4, 4(t1) # pago mayor
            addi t2, t1, 8 # dir deudor_i
            addi t0, t0, -1
            
            while_buscar_mayor_deudor_pagador:
            	beqz t0, end_while_buscar_mayor_deudor_pagador
            	flw ft2, 4(t2)
            	flt.s t3, ft1, ft2 # t3 = 1 => ft1 < ft2 (deuda mayor < deuda_i)
            	beqz t3, while_buscar_mayor_deudor_pagador_continue1
            	    # if t3 == 1 (ft1 < ft2) ()
            	    fmv.s ft1, ft2
            	    mv t1, t2
            	while_buscar_mayor_deudor_pagador_continue1:
            	
            	flt.s t3, ft2, ft4 # t3 = 1 => ft2 < ft4 (deuda_i < deuda menor)
            	beqz t3, while_buscar_mayor_deudor_pagador_continue2
            	    # if t3 == 1 (ft2 < ft4) ()
            	    fmv.s ft4, ft2
            	    mv t4, t2
            	while_buscar_mayor_deudor_pagador_continue2:
            	
            	addi t2, t2, 8
            	addi t0, t0, -1
            	j while_buscar_mayor_deudor_pagador
            end_while_buscar_mayor_deudor_pagador:
            
            mv a0, t1
            mv a1, t4
            
            end_buscar_mayor_deudor_pagador:
            	lw ra, 0(sp)
            	lw ra, 0(sp)
            	lw t0, 8(sp)
            	lw t1, 16(sp)
            	flw ft1, 24(sp)
            	lw t2, 32(sp)
            	flw ft2, 40(sp)
            	lw t3, 48(sp)
            	lw t4, 56(sp)
            	flw ft4, 64(sp)
            	addi sp, sp, 72
                jalr zero, 0(ra)
	
	cargar_gastos_todos:
	    # para cargar todos los gastos
            # registros de entrada son:
            #   dir_gastos -> a2
            #   dir_arreglo -> a3
            #   dir_G -> a4 (G)
            # registros de salida son:
            #   
            # registros temporales son:
            #   t0 -> G, counter
            addi sp, sp, -16
            sw ra, 0(sp)
            sw t0, 8(sp)

            lw t0, 0(a4) # G
            
            while_cargar_gastos_todos:
            	beqz t0, end_while_cargar_gastos_todos
            	
		# cargar gasto
		#mv, a2, a2 # direccion gasto
		#mv a3, a3 # direccion arreglo
		jal ra, cargar_gasto
            	
            	mv a2, a0 # dir gasto = dir sig gasto
            	
            	addi t0, t0, -1
            	j while_cargar_gastos_todos
            end_while_cargar_gastos_todos:
            
            
            end_cargar_gastos_todos:
            	lw ra, 0(sp)
            	lw t0, 8(sp)
            	addi sp, sp, 16
                jalr zero, 0(ra)
                        
	
	cargar_gasto:
            # para cargar un gasto en total
            # registros de entrada son:
            #   dir_gasto -> a2
            #   dir_arreglo -> a3
            # registros de salida son:
            #   dir_sig_gasto -> a0
            # registros temporales son:
            #   id_pagador -> ft0
            #   1 -> ft1
            #   monto -> ft2
            #   n_involucrados -> ft3
            #   t0, t1, t3, t4, t5
            #   counter -> t2
            #   ft4, ft5
            
            addi sp, sp, -104
            sw ra, 0(sp)
            sw t0, 8(sp)
            sw t1, 16(sp)
            sw t2, 24(sp)
            sw t3, 32(sp)
            sw t4, 40(sp)
            sw t5, 48(sp)
            fsw ft0, 56(sp)
            fsw ft1, 64(sp)
            fsw ft2, 72(sp)
            fsw ft3, 80(sp)
            fsw ft4, 88(sp)
            fsw ft5, 96(sp)
            
            mv t0, a2
            
            flw ft0, 0(t0) # id_pagador (float)
            fcvt.w.s t3, ft0 # id_pagador (int)
            flw ft2, 4(t0) # monto
            flw ft3, 8(t0) # No involucrados (float)
            fcvt.w.s t1, ft3 # No involucrados (int)
            
            # anadir gasto a total
            flw ft4, 8(a3) # ft4 = deuda actual
            fadd.s ft4, ft4, ft2 # ft4 = deuda actual + monto
            fsw ft4, 8(a3) # guardar en memoria
            
            # anadir gasto a pagador
            ## buscar dir
	    mv a2, t3 # id
	    mv a3, a3 # dir arreglo
	    jal ra, map_id_address
	    mv t4, a0 # t4 = dir deuda actual
	    ## calcular nueva deuda
	    flw ft4, (t4) # ft4 = deuda actual
	    fsub.s ft4, ft4, ft2 # ft4 = deuda actual - monto
	    ## guardar nueva deuda
	    fsw ft4, (t4) # guardar en memoria
            
            # verificar N <= 0 o no
            fcvt.s.w ft5, zero
            fle.s t5, ft3, ft5 # t5 = 1 if N <= 0; t5 = 0 if N > 0
            beqz t5, if_N_pos_cargar_gasto
            else_cargar_gasto: # N <= 0
            	addi t0, t0, 12 # t0 -> dir sig gasto
            
            	flw ft3, 4(a3) # ft3 = Ntotal (float)
            	lw t1, 0(a3) # t1 = Ntotal (int)
            	fdiv.s ft2, ft2, ft3 # ft2 = monto/N
            	li t2, 0 # counter
            	addi t4, a3, 16 # direccion de deuda de primer participante
            	while_else_cargar_gasto:
            	    beq t2, t1, end_while_else_cargar_gasto # counter == N
            	    
		    # calcular nueva deuda
	            flw ft4, (t4) # ft4 = deuda actual
	            fadd.s ft4, ft4, ft2 # ft4 = deuda actual + monto/N
	            ## guardar nueva deuda
	            fsw ft4, (t4) # guardar en memoria
		    
		    addi t2, t2, 1
		    addi t4, t4, 8 # direccion de deuda de prox participante
            		
            	    j while_else_cargar_gasto
            	end_while_else_cargar_gasto:
            
            	j end_if_N_pos_cargar_gasto
            
            if_N_pos_cargar_gasto: # N > 0
            
            	fdiv.s ft2, ft2, ft3 # ft2 = monto/N
            	addi t0, t0, 12 # dir id_participante
            	li t2, 0 # counter
            	while_N_pos_cargar_gasto:
            	    beq t2, t1, end_while_N_pos_cargar_gasto # counter == N
            	    flw ft0, (t0) # ft0 = id_participante (float)
		    # buscar direccion
            	    fcvt.w.s a2, ft0 # a2 = id_participante (int)
		    mv a3, a3 # dir arreglo
		    jal ra, map_id_address
		    mv t4, a0 # t3 = dir_deuda_i
		    # calcular nueva deuda
	            flw ft4, (t4) # ft4 = deuda actual
	            fadd.s ft4, ft4, ft2 # ft4 = deuda actual + monto/N
	            ## guardar nueva deuda
	            fsw ft4, (t4) # guardar en memoria
		    
		    addi t2, t2, 1
		    addi t0, t0, 4
            	    
            	    j while_N_pos_cargar_gasto
                end_while_N_pos_cargar_gasto:
            
            	j end_if_N_pos_cargar_gasto
            end_if_N_pos_cargar_gasto:
            
            #addi t0, t0, 12 # direccion id_involucrado
            #li t2, 0 # counter
            mv a0, t0 # a0 -> dir sig gasto
            
            end_cargar_gasto:
            	lw ra, 0(sp)
            	lw t0, 8(sp)
            	lw t1, 16(sp)
            	lw t2, 24(sp)
            	lw t3, 32(sp)
            	lw t4, 40(sp)
            	lw t5, 48(sp)
            	flw ft0, 56(sp)
            	flw ft1, 64(sp)
            	flw ft2, 72(sp)
            	flw ft3, 80(sp)
            	flw ft4, 88(sp)
            	flw ft5, 96(sp)
            	addi sp, sp, 104
                jalr zero, 0(ra)
	
	map_id_address:
	    # para conseguir la direccion con deuda por id
            # registros de entrada son:
            #   id -> a2
            #   dir_arreglo_deudas -> a3
            # registros de salida son:
            #   address -> a0
            # registros temporales son:
            #   counter -> t0
            #   temp_id -> t1
            
            addi sp, sp, -24
            sw ra, 0(sp)
            sw t0, 8(sp)
            sw t1, 16(sp)
            
            mv t0, a3
            addi t0, t0, 12
            
            while_map_id_address:
            	lw t1, 0(t0)  # get temp_id
            	beq t1, a2, end_while_map_id_address  # if id_temp == id -> exit while
            	
            	addi t0, t0, 8
            	j while_map_id_address
            
            end_while_map_id_address:
            addi t0, t0, 4
            mv a0, t0
            
            end_map_id_address:
            	lw ra, 0(sp)
            	lw t0, 8(sp)
            	lw t1, 16(sp)
            	addi sp, sp, 24
                jalr zero, 0(ra)
	
	crear_arreglo_gastos:
	    # funcion que crea un espacio en memoria para almacenar datos
	    # ESTRUCTURA: 
	    #   N (int)
	    #   N (float)
	    # 	gastos_totales
	    #   id_0
	    #   persona(id_0) debe
	    #   id_1
	    #   persona(id_1) debe
	    #   ...
            # registros de entrada son:
            #   direccion_0 -> a2
            #   dir nro_personas -> a3 (=N)
            #   direccion ids -> a4 (=amigues)
            # registros de salida son:
            # registros temporales son:
            #   t0, t1, ft0
            
            addi sp, sp, -56
            sw ra, 0(sp)
            sw t0, 8(sp)
            sw t1, 16(sp)
            sw t2, 24(sp)
            sw t3, 32(sp)
            sw t4, 40(sp)
            fsw ft0, 48(sp)
            
	    lw t0, 0(a3) # t0 = N
	    li t1, 0
	    mv t2, a2 # t2 = direccion_0
	    mv t3, a4 # t3 = direccion ids
	    
	    sw t0, (t2) # guardo N (int)
	    addi t2, t2, 4
	    
	    fcvt.s.w ft0, t0
	    fsw ft0, (t2) # guardo N (float)
	    addi t2, t2, 4
	    
	    sw zero, (t2) # guardo suma_total = 0
	    addi t2, t2, 4

	    fcvt.s.w ft0, zero # valor 0 (float)
	    
	    while_crear_arreglo_gastos:
	    	beq t1, t0, end_while_crear_arreglo_gastos
	    	
	    	lw t4, (t3) # t4 = id_i
	    	sw t4, (t2) # guardo id_i en direccion
	    	addi t3, t3, 4 # dir_id = dir_id + 4
	    	addi t2, t2, 4 # dir = dir + 4
	    	
	    	fsw ft0, (t2) # guardo deuda=0 en dir
	    	addi t2, t2, 4 # dir = dir + 4
	    	
	    	addi t1, t1, 1
	    	j while_crear_arreglo_gastos
	    
	    end_while_crear_arreglo_gastos:
            
            end_crear_arreglo_gastos:
            	lw ra, 0(sp)
            	lw t0, 8(sp)
            	lw t1, 16(sp)
            	lw t2, 24(sp)
            	lw t3, 32(sp)
            	lw t4, 40(sp)
            	flw ft0, 48(sp)
            	addi sp, sp, 56
                jalr zero, 0(ra)
       
       end_all:
       
		
