.globl  start
.data
.text

    start:
        # aca va su codigo  :3

        li a0, -1
        jal ra, heaviside

        li a0, 1
        jal ra, heaviside
        
        j end

        heaviside:
            # H(x) = 0 if x <= 0 else 1
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
                jalr zero, 0(ra)
    
    end:

