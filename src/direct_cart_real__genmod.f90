        !COMPILER-GENERATED INTERFACE MODULE: Thu Apr 20 14:39:31 2023
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE DIRECT_CART_REAL__genmod
          INTERFACE 
            SUBROUTINE DIRECT_CART_REAL(R1,R2,LATTICE)
              REAL(KIND=8), INTENT(IN) :: R1(3)
              REAL(KIND=8), INTENT(INOUT) :: R2(3)
              REAL(KIND=8), INTENT(IN) :: LATTICE(3,3)
            END SUBROUTINE DIRECT_CART_REAL
          END INTERFACE 
        END MODULE DIRECT_CART_REAL__genmod
