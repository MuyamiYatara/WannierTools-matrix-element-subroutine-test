        !COMPILER-GENERATED INTERFACE MODULE: Thu Apr 20 14:39:31 2023
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE WRITEOUT_POSCAR__genmod
          INTERFACE 
            SUBROUTINE WRITEOUT_POSCAR(CELL,POSCARNAME)
              USE PARA
              TYPE (CELL_TYPE) :: CELL
              CHARACTER(*) :: POSCARNAME
            END SUBROUTINE WRITEOUT_POSCAR
          END INTERFACE 
        END MODULE WRITEOUT_POSCAR__genmod
