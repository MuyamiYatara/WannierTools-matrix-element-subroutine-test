  �  ^   k820309    �          2021.7.1    #v�d                                                                                                          
       module.f90 ME_CALCULATE                                                     
                                                                                                                                                              
                 
                 -DT�!	@        3.14159265358979D0          @  @                                   
                 @  @                                   
                 @  @                                   
                                                                                                         �?(0.0D0,1.0D0)          @  @                                   
                                                    	                                                      7                                             
                                                      4#         @                                                      #NAME    #INDEX_              
                                      
                                                                             #         @                                                      #NAME    #CONFIGURATION              
                                      
                                                                                         p          p          p            p          p                          #         @                                                      #N    #RES              
                                                                                                                                                      	                 	                 (x?            5.29177210903E-1#         @                                                      #ORBITAL_NAME    #INDEX_L    #INDEX_M              
                                      
                                                                                                                                    #         @                                                      #NAME    #V_CONFIGURATION              
                                      
                                                                                         p          p          p            p          p                                                                                              @                                   
                                                       
                                                       
                                                        
       #         @                                  !                    #L "   #M #   #DL $   #DM %   #GAUNT_VALUE &                                              "                                                       #                                                       $                                                       %                      D                                &     
       #         @                                  '                    #POLAR_EPSILON (             D                                (                        p          p            p                          #         @                                  )                    #NAME *   #N +   #L ,   #Z_EFF -             
  @                              *     
                                
                                  +                     
                                  ,                     D                                -     
       %         @                               .                    
       #R /   #N 0   #Z_EFF 1             
                                 /     
                
                                  0                     
                                 1     
      %         @                               2                    
       #X 3   #L 4             D @                              3     
                 
                                  4           %         @                               5                           #THETA 6   #PHI 7   #L 8   #M 9             
  @                              6     
                
  @                              7     
                
                                  8                     
  @                               9           %         @  @                            :                    
       #R ;   #K_F <   #NAME =   #N >   #L ?             
  @                              ;     
                
                                 <     
                
  @                              =     
                                
  @                               >                     
  @                               ?           #         @                                  @                    #A A   #B B   #FUNC C   #K_F D   #NAME E   #N F   #L G   #ANS H             
                                 A     
                
                                 B     
      "         �                              C       
               
@ @                              D     
                
@ @                              E     
                                
@ @                               F                     
@ @                               G                     D                                H     
       #         @                                   I                 
   #A J   #B K   #IS_A_INF L   #IS_B_INF M   #FUNC N   #K_F O   #NAME P   #N Q   #L R   #ANS S             
                                 J     
                
                                 K     
                
                                  L                     
                                  M           "         � @                            N       
               
  @                              O     
                
  @                              P     
                                
  @                               Q                     
  @                               R                     D                                S     
       #         @                                  T                    #K_CART U   #K_F V   #THETA W   #PHI X             
                                 U                   
    p          p            p                                    D                                V     
                 D                                W     
                 D                                X     
       #         @                                   Y                    #ELE_NAME Z   #ORB_NAME [   #K_CART \   #MATRIX_ELEMENT_RES ]             
  @                              Z     
                                
  @                              [     
                                 @                              \                   
     p          p            p                                    D                                ]               �          fn#fn    �   @   J   ELEMENT_TABLE       p       DP+PREC    p  �       PI+PARA ,   �  @       POLARIZATION_PHI_ARPES+PARA +   2  @       POLARIZATION_XI_ARPES+PARA .   r  @       POLARIZATION_DELTA_ARPES+PARA    �  }       ZI+PARA .   /  @       POLARIZATION_ALPHA_ARPES+PARA -   o  q       LINES_OF_TABLE+ELEMENT_TABLE -   �  q       ANGULAR_NUMBER+ELEMENT_TABLE 0   Q  ^       GET_ELEMENT_INDEX+ELEMENT_TABLE 5   �  P   a   GET_ELEMENT_INDEX%NAME+ELEMENT_TABLE 7   �  @   a   GET_ELEMENT_INDEX%INDEX_+ELEMENT_TABLE 2   ?  e       GET_ELECTRON_CONFIG+ELEMENT_TABLE 7   �  P   a   GET_ELECTRON_CONFIG%NAME+ELEMENT_TABLE @   �  �   a   GET_ELECTRON_CONFIG%CONFIGURATION+ELEMENT_TABLE (   �  X       FACTORIAL+ELEMENT_TABLE *      @   a   FACTORIAL%N+ELEMENT_TABLE ,   @  @   a   FACTORIAL%RES+ELEMENT_TABLE "   �  �       A_0+ELEMENT_TABLE 0      t       GET_ORBITAL_INDEX+ELEMENT_TABLE =   t  P   a   GET_ORBITAL_INDEX%ORBITAL_NAME+ELEMENT_TABLE 8   �  @   a   GET_ORBITAL_INDEX%INDEX_L+ELEMENT_TABLE 8   	  @   a   GET_ORBITAL_INDEX%INDEX_M+ELEMENT_TABLE 1   D	  g       GET_VALENCE_CONFIG+ELEMENT_TABLE 6   �	  P   a   GET_VALENCE_CONFIG%NAME+ELEMENT_TABLE A   �	  �   a   GET_VALENCE_CONFIG%V_CONFIGURATION+ELEMENT_TABLE    �
  @       P_NUM    �
  @       INTE_B "   /  @       CONVERGENCE_DELTA    o  @       INTE_STEP    �  @       K_CART_ABS    �  w       GAUNT    f  @   a   GAUNT%L    �  @   a   GAUNT%M    �  @   a   GAUNT%DL    &  @   a   GAUNT%DM "   f  @   a   GAUNT%GAUNT_VALUE $   �  [       POLARIZATION_VECTOR 2     �   a   POLARIZATION_VECTOR%POLAR_EPSILON    �  k       Z_EFF_CAL       P   a   Z_EFF_CAL%NAME    P  @   a   Z_EFF_CAL%N    �  @   a   Z_EFF_CAL%L     �  @   a   Z_EFF_CAL%Z_EFF      i       SLATER_RN    y  @   a   SLATER_RN%R    �  @   a   SLATER_RN%N     �  @   a   SLATER_RN%Z_EFF !   9  ^       SPHERICAL_BESSEL #   �  @   a   SPHERICAL_BESSEL%X #   �  @   a   SPHERICAL_BESSEL%L      r       YLM    �  @   a   YLM%THETA    �  @   a   YLM%PHI    	  @   a   YLM%L    I  @   a   YLM%M    �  x       INTEGRAND      @   a   INTEGRAND%R    A  @   a   INTEGRAND%K_F    �  P   a   INTEGRAND%NAME    �  @   a   INTEGRAND%N      @   a   INTEGRAND%L !   Q  �       INTEGRAL_SIMPSON #   �  @   a   INTEGRAL_SIMPSON%A #     @   a   INTEGRAL_SIMPSON%B &   [  @      INTEGRAL_SIMPSON%FUNC %   �  @   a   INTEGRAL_SIMPSON%K_F &   �  P   a   INTEGRAL_SIMPSON%NAME #   +  @   a   INTEGRAL_SIMPSON%N #   k  @   a   INTEGRAL_SIMPSON%L %   �  @   a   INTEGRAL_SIMPSON%ANS    �  �       INF_INTEGRAL    �  @   a   INF_INTEGRAL%A    �  @   a   INF_INTEGRAL%B &     @   a   INF_INTEGRAL%IS_A_INF &   Q  @   a   INF_INTEGRAL%IS_B_INF "   �  @      INF_INTEGRAL%FUNC !   �  @   a   INF_INTEGRAL%K_F "     P   a   INF_INTEGRAL%NAME    a  @   a   INF_INTEGRAL%N    �  @   a   INF_INTEGRAL%L !   �  @   a   INF_INTEGRAL%ANS '   !  q       CARTESIAN_TO_SPHERICAL .   �  �   a   CARTESIAN_TO_SPHERICAL%K_CART +   &  @   a   CARTESIAN_TO_SPHERICAL%K_F -   f  @   a   CARTESIAN_TO_SPHERICAL%THETA +   �  @   a   CARTESIAN_TO_SPHERICAL%PHI #   �  �       GET_MATRIX_ELEMENT ,   n  P   a   GET_MATRIX_ELEMENT%ELE_NAME ,   �  P   a   GET_MATRIX_ELEMENT%ORB_NAME *     �   a   GET_MATRIX_ELEMENT%K_CART 6   �  @   a   GET_MATRIX_ELEMENT%MATRIX_ELEMENT_RES 