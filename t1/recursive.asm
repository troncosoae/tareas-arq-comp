.globl  start
.data
.text

    start:
        # aca va su codigo  :3

        li a0, 5
        jal ra, recursive
        
        j end

        recursive:
            # H(x) = 0 if x <= 0 else 1
            # registros de entrada son:
            #   x -> a0
            # registros de salida son:
            #   x -> a0
            # registros temporales son: 
            #   ...
            addi sp, sp, -16
            sw x1, 8(sp)
            sw a0, 0(sp)

            addi x5, a0, -1
            bge, x5, x0, L1

                addi a0, x0, 1
                addi sp, sp, 16
                jalr x0, 0(x1)

            L1: 
                addi a0, a0, -1
                jal x1, recursive

                addi x6, a0, 0
                lw a0, 0(sp)
                lw x1, 8(sp)
                addi sp, sp, 16

                mul a0, a0, x6
                jalr x0, 0(x1)

    end:

