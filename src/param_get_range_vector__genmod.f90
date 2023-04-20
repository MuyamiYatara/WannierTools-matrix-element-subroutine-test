        !COMPILER-GENERATED INTERFACE MODULE: Thu Apr 20 14:39:31 2023
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE PARAM_GET_RANGE_VECTOR__genmod
          INTERFACE 
            SUBROUTINE PARAM_GET_RANGE_VECTOR(KEYWORD,INLINE,LENGTH,    &
     &LCOUNT,I_VALUE)
              INTEGER(KIND=4), INTENT(INOUT) :: LENGTH
              CHARACTER(*), INTENT(IN) :: KEYWORD
              CHARACTER(*), INTENT(INOUT) :: INLINE
              LOGICAL(KIND=4), INTENT(IN) :: LCOUNT
              INTEGER(KIND=4), INTENT(OUT) :: I_VALUE(LENGTH)
            END SUBROUTINE PARAM_GET_RANGE_VECTOR
          END INTERFACE 
        END MODULE PARAM_GET_RANGE_VECTOR__genmod
