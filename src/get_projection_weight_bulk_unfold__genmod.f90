        !COMPILER-GENERATED INTERFACE MODULE: Fri Mar 31 09:21:04 2023
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE GET_PROJECTION_WEIGHT_BULK_UNFOLD__genmod
          INTERFACE 
            SUBROUTINE GET_PROJECTION_WEIGHT_BULK_UNFOLD(NDIM,          &
     &K_SBZ_DIRECT,K_PBZ_DIRECT,PSI,WEIGHT,ORIGINCELL,                  &
     &NUMBEROFSELECTEDORBITALS_GROUPS,NUMBEROFSELECTEDORBITALS,         &
     &SELECTED_WANNIERORBITALS)
              USE PARA, ONLY :                                          &
     &          DP,                                                     &
     &          PROJECTION_WEIGHT_MODE,                                 &
     &          CPUID,                                                  &
     &          STDOUT,                                                 &
     &          NRPTS,                                                  &
     &          IRVEC,                                                  &
     &          FOLDED_CELL,                                            &
     &          PI2ZI,                                                  &
     &          EPS3,                                                   &
     &          CELL_TYPE,                                              &
     &          INT_ARRAY1D,                                            &
     &          LANDAULEVEL_UNFOLD_LINE_CALC
              INTEGER(KIND=4), INTENT(IN) ::                            &
     &NUMBEROFSELECTEDORBITALS_GROUPS
              INTEGER(KIND=4), INTENT(IN) :: NDIM
              REAL(KIND=8), INTENT(IN) :: K_SBZ_DIRECT(3)
              REAL(KIND=8), INTENT(IN) :: K_PBZ_DIRECT(3)
              COMPLEX(KIND=8), INTENT(IN) :: PSI(NDIM)
              REAL(KIND=8), INTENT(OUT) :: WEIGHT(                      &
     &NUMBEROFSELECTEDORBITALS_GROUPS)
              TYPE (CELL_TYPE) :: ORIGINCELL
              INTEGER(KIND=4), INTENT(IN) :: NUMBEROFSELECTEDORBITALS(  &
     &NUMBEROFSELECTEDORBITALS_GROUPS)
              TYPE (INT_ARRAY1D) :: SELECTED_WANNIERORBITALS(           &
     &NUMBEROFSELECTEDORBITALS_GROUPS)
            END SUBROUTINE GET_PROJECTION_WEIGHT_BULK_UNFOLD
          END INTERFACE 
        END MODULE GET_PROJECTION_WEIGHT_BULK_UNFOLD__genmod
