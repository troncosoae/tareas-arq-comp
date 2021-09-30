.globl  start
.data
.text

    start:
        # aca va su codigo  :3

        li a0, 13
        li a1, 3
        jal ra, module
        
        j end

        module:
            # z = x % y
            # registros de entrada son:
            #   x -> a0
            #   y -> a1
            # registros de salida son:
            #   z -> a2
            # registros temporales son: 
            #   t0
            
            li t0, 0
            
            j while
            
            while:
            	bgt t0, a0, end_while
            	add t0, t0, a1
            	j while
            
            end_while:
            sub t0, t0, a1
            
            sub a2, a0, t0
            
            j end_module
            
            end_module:
                jalr zero, 0(ra)
    
    end:

