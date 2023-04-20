        !COMPILER-GENERATED INTERFACE MODULE: Thu Apr 20 14:39:31 2023
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE GET_RECIPROCAL_LATTICE__genmod
          INTERFACE 
            SUBROUTINE GET_RECIPROCAL_LATTICE(R1,R2,R3,K1,K2,K3)
              REAL(KIND=8), INTENT(IN) :: R1(3)
              REAL(KIND=8), INTENT(IN) :: R2(3)
              REAL(KIND=8), INTENT(IN) :: R3(3)
              REAL(KIND=8), INTENT(OUT) :: K1(3)
              REAL(KIND=8), INTENT(OUT) :: K2(3)
              REAL(KIND=8), INTENT(OUT) :: K3(3)
            END SUBROUTINE GET_RECIPROCAL_LATTICE
          END INTERFACE 
        END MODULE GET_RECIPROCAL_LATTICE__genmod
