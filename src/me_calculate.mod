  �  Q   k820309    �          2021.7.1    �/d                                                                                                          
       module.f90 ME_CALCULATE                                                     
                                                                                                                                                                                                                7                                                                                                   4#         @                                                      #NAME    #INDEX_              
                                      
                                                                             #         @                                                      #NAME 	   #CONFIGURATION 
             
                                 	     
                                                                 
                        p          p          p            p          p                          #         @                                                      #N    #RES              
                                                                                                                                                      	                 	                 (x?            5.29177210903E-1                                                 
                 
                 -DT�!	@        3.14159265358979D0                                                                                                  �?(0.0D0,1.0D0)#         @                                                      #ORBITAL_NAME    #INDEX_L    #INDEX_M              
                                      
                                                                                                                                    #         @                                                      #NAME    #V_CONFIGURATION              
                                      
                                                                                         p          p          p            p          p                                                                                              @                                   
                                                       
                                                       
       #         @                                                      #NAME    #N    #L    #Z_EFF               
  @                                   
                                
                                                       
                                                       D                                      
       %         @                               !                    
       #R "   #N #   #Z_EFF $             
                                 "     
                
                                  #                     
                                 $     
      %         @                               %                    
       #X &   #L '             D @                              &     
                 
                                  '           %         @                               (                           #THETA )   #PHI *   #L +   #M ,             
  @                              )     
                
                                 *     
                
                                  +                     
  @                               ,           %         @  @                            -                    
       #R .   #K_F /   #NAME 0   #N 1   #L 2             
  @                              .     
                
                                 /     
                
  @                              0     
                                
  @                               1                     
  @                               2           #         @                                  3                    #A 4   #B 5   #FUNC 6   #K_F 7   #NAME 8   #N 9   #L :   #ANS ;             
                                 4     
                
                                 5     
      "         �                              6       
               
@ @                              7     
                
@ @                              8     
                                
@ @                               9                     
@ @                               :                     D                                ;     
       #         @                                   <                 
   #A =   #B >   #IS_A_INF ?   #IS_B_INF @   #FUNC A   #K_F B   #NAME C   #N D   #L E   #ANS F             
                                 =     
                
                                 >     
                
                                  ?                     
                                  @           "         � @                            A       
               
  @                              B     
                
  @                              C     
                                
  @                               D                     
  @                               E                     D                                F     
       #         @                                  G                    #K_CART H   #K_F I   #THETA J   #PHI K             
                                 H                   
    p          p            p                                    D                                I     
                 D                                J     
                 D                                K     
       #         @                                   L                    #ELE_NAME M   #ORB_NAME N   #K_CART O   #MATRIX_ELEMENT_RES P             
  @                              M     
                                
  @                              N     
                                
  @                              O                   
    p          p            p                                    D                                P               �          fn#fn    �   @   J   ELEMENT_TABLE       p       DP+PREC -   p  q       LINES_OF_TABLE+ELEMENT_TABLE -   �  q       ANGULAR_NUMBER+ELEMENT_TABLE 0   R  ^       GET_ELEMENT_INDEX+ELEMENT_TABLE 5   �  P   a   GET_ELEMENT_INDEX%NAME+ELEMENT_TABLE 7      @   a   GET_ELEMENT_INDEX%INDEX_+ELEMENT_TABLE 2   @  e       GET_ELECTRON_CONFIG+ELEMENT_TABLE 7   �  P   a   GET_ELECTRON_CONFIG%NAME+ELEMENT_TABLE @   �  �   a   GET_ELECTRON_CONFIG%CONFIGURATION+ELEMENT_TABLE (   �  X       FACTORIAL+ELEMENT_TABLE *     @   a   FACTORIAL%N+ELEMENT_TABLE ,   A  @   a   FACTORIAL%RES+ELEMENT_TABLE "   �  �       A_0+ELEMENT_TABLE      �       PI+PARA    �  }       ZI+PARA 0      t       GET_ORBITAL_INDEX+ELEMENT_TABLE =   t  P   a   GET_ORBITAL_INDEX%ORBITAL_NAME+ELEMENT_TABLE 8   �  @   a   GET_ORBITAL_INDEX%INDEX_L+ELEMENT_TABLE 8     @   a   GET_ORBITAL_INDEX%INDEX_M+ELEMENT_TABLE 1   D  g       GET_VALENCE_CONFIG+ELEMENT_TABLE 6   �  P   a   GET_VALENCE_CONFIG%NAME+ELEMENT_TABLE A   �  �   a   GET_VALENCE_CONFIG%V_CONFIGURATION+ELEMENT_TABLE    �	  @       P_NUM    �	  @       INTE_B "   /
  @       CONVERGENCE_DELTA    o
  @       INTE_STEP    �
  k       Z_EFF_CAL      P   a   Z_EFF_CAL%NAME    j  @   a   Z_EFF_CAL%N    �  @   a   Z_EFF_CAL%L     �  @   a   Z_EFF_CAL%Z_EFF    *  i       SLATER_RN    �  @   a   SLATER_RN%R    �  @   a   SLATER_RN%N       @   a   SLATER_RN%Z_EFF !   S  ^       SPHERICAL_BESSEL #   �  @   a   SPHERICAL_BESSEL%X #   �  @   a   SPHERICAL_BESSEL%L    1  r       YLM    �  @   a   YLM%THETA    �  @   a   YLM%PHI    #  @   a   YLM%L    c  @   a   YLM%M    �  x       INTEGRAND      @   a   INTEGRAND%R    [  @   a   INTEGRAND%K_F    �  P   a   INTEGRAND%NAME    �  @   a   INTEGRAND%N    +  @   a   INTEGRAND%L !   k  �       INTEGRAL_SIMPSON #   �  @   a   INTEGRAL_SIMPSON%A #   5  @   a   INTEGRAL_SIMPSON%B &   u  @      INTEGRAL_SIMPSON%FUNC %   �  @   a   INTEGRAL_SIMPSON%K_F &   �  P   a   INTEGRAL_SIMPSON%NAME #   E  @   a   INTEGRAL_SIMPSON%N #   �  @   a   INTEGRAL_SIMPSON%L %   �  @   a   INTEGRAL_SIMPSON%ANS      �       INF_INTEGRAL    �  @   a   INF_INTEGRAL%A    �  @   a   INF_INTEGRAL%B &   +  @   a   INF_INTEGRAL%IS_A_INF &   k  @   a   INF_INTEGRAL%IS_B_INF "   �  @      INF_INTEGRAL%FUNC !   �  @   a   INF_INTEGRAL%K_F "   +  P   a   INF_INTEGRAL%NAME    {  @   a   INF_INTEGRAL%N    �  @   a   INF_INTEGRAL%L !   �  @   a   INF_INTEGRAL%ANS '   ;  q       CARTESIAN_TO_SPHERICAL .   �  �   a   CARTESIAN_TO_SPHERICAL%K_CART +   @  @   a   CARTESIAN_TO_SPHERICAL%K_F -   �  @   a   CARTESIAN_TO_SPHERICAL%THETA +   �  @   a   CARTESIAN_TO_SPHERICAL%PHI #      �       GET_MATRIX_ELEMENT ,   �  P   a   GET_MATRIX_ELEMENT%ELE_NAME ,   �  P   a   GET_MATRIX_ELEMENT%ORB_NAME *   (  �   a   GET_MATRIX_ELEMENT%K_CART 6   �  @   a   GET_MATRIX_ELEMENT%MATRIX_ELEMENT_RES 