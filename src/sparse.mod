  fR  Ç   k820309    ð          2021.7.1    Bäd                                                                                                          
       sparse.f90 SPARSE       +       WTCSR WTPARCSR WTPARVEC CONVERTCOOTOCSR WTCSRCREATE WTCSRDESTROY WTCSRINITIALIZE WTSEQVECCREATE WTSEQVECDESTROY WTSEQVECINITIALIZE WTSEQVECPRINT WTSEQVECINNERPROD WTCSRTOPARCSR WTPARCSRCREATE WTPARCSRINITIALIZE WTPARCSRDESTROY WTGENSENDRECV WTSENDRECVDESTROY WTPARVECCREATE WTPARVECDESTROY WTPARVECINITIALIZE WTPARVECPRINT WTPARVECCOPY WTPARVECNORM WTPARVECAXPY WTPARVECAXPBY WTPARVECINNERPROD WTPARVECINNERPRODWITHNOREDUCE WTPARVECNORMALIZE WTPARVECGETSINGLEVALUE WTPARVECSETRANDOMVALUE WTPARVECSETSEQVALUE WTPARCSRMATRIXCREATE CSR_SORT_INDICES CSR_SUM_DUPLICATES ARPACK_SPARSE_COO_EIGS MAXNUMNONZEROS i@| i@ u@DOT gen@WTPARCSRMATVEC gen@WTPARVECSETCONSTANTVALUE gen@WTPARVECSETSINGLEVALUE          @                                         
                                                           
                                                           
                                                                 |  #WTPARVECCOPY    #WTPARVECSETCONSTANTVALUE_Z    #WTPARVECSETCONSTANTVALUE_R 	   #         @     @X                                                 #PARVEC    #VAL              D @                                                   #WTPARVEC              
  @                                         #         @     @X                             	                    #PARVEC 
   #VAL              D @                               
                    #WTPARVEC              
  @                                   
                                                                 #WTPARVECINNERPROD    #WTPARVECSCALE_R1    #WTPARVECSCALE_R2    #WTPARVECSCALE_Z1    #WTPARVECSCALE_Z2    &         @   @X                                                      #A    #X    #WTPARVEC              
  @                                   
                
@ P                                                  #WTPARVEC    &         @   @X                                                       #X    #A    #WTPARVEC              
@ P                                                  #WTPARVEC              
  @                                   
      &         @   @X                                                       #A    #X    #WTPARVEC              
  @                                                   
@ P                                                  #WTPARVEC    &         @   @X                                                       #X    #A    #WTPARVEC              
@ P                                                  #WTPARVEC              
  @                                                                                                   o #WTPARVECINNERPRODWITHNOREDUCE                                                           u #WTPARCSRMATVEC_C    #         @     @X                                                 #HPARCSR    #VEC_IN    #VEC_OUT              
                                                    #WTPARCSR              
@ @                                                  #WTPARVEC                                                                   #WTPARVEC                                                           u #WTPARVECSETCONSTANTVALUE_Z    #WTPARVECSETCONSTANTVALUE_R 	                                                          u #WTPARVECSETSINGLEVALUE_R    #WTPARVECSETSINGLEVALUE_Z #   #         @     @X                                                 #PARVEC     #I !   #VAL "             D @                                                    #WTPARVEC              
  @                              !                     
  @                              "     
      #         @     @X                             #                    #PARVEC $   #I %   #VAL &             D @                               $                    #WTPARVEC              
  @                              %                     
  @                              &                         @  @                          '     'x                   #COMM (   #NUMSENDS )   #SENDCPUS *   #SENDMAPSTARTS +   #SENDMAPELEMENTS ,   #NUMRECVS -   #RECVCPUS .   #RECVVECSTARTS /                                               (                                                               )                                                            *                                         &                                                                                     +            P                             &                                                                                    ,                                         &                                                                                       -     à                                                       .            è                             &                                                                                     /            0                            &                                                          @  @                           0     'è                    #SENDRECV 1   #NUMREQUEST 2   #MPIREQUEST 3   #SENDDATA 4   #RECVDATA 5                                              1     x                     #WTPARCSRCOMM '                                               2                                                            3                                         &                                                                                    4            X                             &                                                                                    5                                          &                                                             @                          6     '0                   #NUMROWS 7   #NUMCOLS 8   #NUMNONZEROS 9   #ROWINDEX :   #IA ;   #JA <   #A =                 $                             7                                 $                             8                                $                             9                              $                             :                                         &                                                       $                             ;            X                             &                                                       $                             <                                          &                                                       $                             =            è                             &                                                             @                                '                   #COMM >   #GLOBALNUMROWS ?   #GLOBALNUMCOLS @   #NUMNONZEROS A   #DIAG B   #OFFD C   #COLMAPOFFD D   #ROWSTARTS E   #COLSTARTS F   #ISCOMM G   #SENDRECV H                 $                              >                                 $                             ?                                $                             @                                $                             A                               $                              B     0                    #WTCSR 6                $                              C     0                    #WTCSR 6               $                             D                                          &                                                       $                             E            h                             &                                                       $                             F            °              	               &                                                         $                              G     ø       
                   $                              H     x                    #WTPARCSRCOMM '                 @  @                          I     'P                    #LENGTH J   #DATA K                                              J                                                            K                                         &                                                             @                                '                    #COMM L   #GLOBALLENGTH M   #FIRSTINDEX N   #LASTINDEX O   #SEQVEC P                 $                              L                                 $                             M                                $                             N                                $                             O                               $                              P     P                     #WTSEQVEC I   #         @      X                                                 #Y Q   #X R              @                               Q                    #WTPARVEC              
                                  R                   #WTPARVEC    %         @    X                                                     #BRA S   #KET T             
@ @                               S                   #WTPARVEC              
                                  T                   #WTPARVEC    %         @    X                                                      #BRA U   #KET V             
                                  U                   #WTPARVEC              
                                  V                   #WTPARVEC                                                W            #         @                                  X                    #N Y   #NNZ Z   #A [   #IA \   #JA ]   #IWK ^             
                                 Y                     
                                 Z                    
D                                [                         p          5  p        r Z       5  p        r Z                              
D                                \                         p          5  p        r Z       5  p        r Z                              
D                                ]                         p          5  p        r Z       5  p        r Z                              
D                                ^                         p           5  p        r Y   n                                       1     5  p        r Y   n                                      1                           #         @                                  _                    #NROWS `   #NCOLS a   #MAXNNZ b   #HCSR c             
                                 `                     
                                 a                     
                                 b                     
D                                 c     0              #WTCSR 6   #         @                                  d                    #HCSR e             D                                 e     0              #WTCSR 6   #         @                                  f                    #HCSR g             D                                 g     0              #WTCSR 6   #         @                                  h                    #LENGTH i   #VEC j             
                                 i                     D                                 j     P               #WTSEQVEC I   #         @                                  k                    #VEC l             D                                 l     P               #WTSEQVEC I   #         @                                  m                    #VEC n             D                                 n     P               #WTSEQVEC I   #         @                                   o                    #SEQVEC p             
                                  p     P              #WTSEQVEC I   %         @                              q                           #BRA r   #KET s             
                                  r     P              #WTSEQVEC I             
                                  s     P              #WTSEQVEC I   #         @                                   t                    #HCSR u   #HPARCSR v                                              u     0              #WTCSR 6             D @                               v                   #WTPARCSR    #         @                                  w                    #COMM x   #ROWSTARTS y   #COLSTARTS z   #NUMNONZEROSDIAG {   #NUMNONZEROSOFFD |   #HPARCSR }             
@ @                               x                                                     y                    	              &                                                                                     z                    
              &                                                     
  @                              {                     
  @                              |                     D @                               }                   #WTPARCSR    #         @                                   ~                    #HPARCSR              D @                                                  #WTPARCSR    #         @                                                       #HPARCSR              D @                                                  #WTPARCSR    #         @                                                       #HPARCSR              
D                                                    #WTPARCSR    #         @                                                      #SENDRECV              D                                      x              #WTPARCSRCOMM '   #         @                                                       #COMM    #GLOBALLENGTH    #PARVEC              
@ @                                                    
  @                                                   D @                                                   #WTPARVEC    #         @                                                       #PARVEC              D @                                                   #WTPARVEC    #         @                                                       #PARVEC              D @                                                   #WTPARVEC    #         @                                                       #PARVEC              
                                                     #WTPARVEC    %         @                                                    
       #X              
                                                     #WTPARVEC    #         @                                                       #A    #X    #Y              
  @                                                   
                                                     #WTPARVEC              
 @                                                   #WTPARVEC    #         @                                                       #A    #X    #B    #Y              
  @                                                   
                                                     #WTPARVEC              
  @                                                   
 @                                                   #WTPARVEC    #         @                                                       #X              D P                                                   #WTPARVEC    %         @                                                            #PARVEC    #I              
                                                     #WTPARVEC              
  @                                         #         @                                                        #PARVEC ¡             D @                               ¡                    #WTPARVEC    #         @                                   ¢                    #PARVEC £             D @                               £                    #WTPARVEC    #         @                                   ¤                    #MDIM ¥   #HPARCSR ¦             
  @                               ¥                     D @                               ¦                   #WTPARCSR    #         @                                  §                    #N ¨   #NNZ ©   #AP ª   #AJ «   #AX ¬                                                                   
                                  ¨                     
                                  ©                    
                                 ª                     5    p           5  p        r ¨   n                                       1     5  p        r ¨   n                                      1                                    
D                                 «                     6    p          5  p        r ©       5  p        r ©                              
D                                ¬                     7    p          5  p        r ©       5  p        r ©                     #         @                                  ­                    #N ®   #NNZ ¯   #IA °   #JA ±   #A_VAL ²                                        
                                  ®                     
D                                 ¯                     
D                                 °                     =    p           5  p        r ®   n                                       1     5  p        r ®   n                                      1                                    
D                                 ±                     >    p          5  p        r ¯       5  p        r ¯                              
D                                ²                     ?    p          5  p        r ¯       5  p        r ¯                     #         @                                   ³                    #NDIMS ´   #NNZMAX µ   #NNZ ¶   #ACOO ·   #JCOO ¸   #ICOO ¹   #NEVAL º   #NVECS »   #DEVAL ¼   #SIGMA ½   #ZEIGV ¾   #RITZVEC ¿                                            
 @                               ´                      
  @                               µ                     
D @                               ¶                     
D @                              ·                     @    p          5  p        r µ       5  p        r µ                              
D @                               ¸                     A    p          5  p        r µ       5  p        r µ                              
D @                               ¹                     B    p          5  p        r µ       5  p        r µ                               
  @                               º                     
  @                               »                    D @                              ¼                    
 C    p          5  p        r º       5  p        r º                               
  @                              ½                    D @                              ¾                     D      p        5  p        r ´   p          5  p        r ´     5  p        r »       5  p        r ´     5  p        r »                               
  @                               ¿                        fn#fn    º   Å  b   uapp(SPARSE      @   J  PREC    ¿  @   J  WMPI    ÿ  @   J  PARA    ?        i@| +   Ñ  ]      WTPARVECSETCONSTANTVALUE_Z 2   .  V   a   WTPARVECSETCONSTANTVALUE_Z%PARVEC /     @   a   WTPARVECSETCONSTANTVALUE_Z%VAL +   Ä  ]      WTPARVECSETCONSTANTVALUE_R 2   !  V   a   WTPARVECSETCONSTANTVALUE_R%PARVEC /   w  @   a   WTPARVECSETCONSTANTVALUE_R%VAL    ·  ¯      i@ !   f  l      WTPARVECSCALE_R1 #   Ò  @   a   WTPARVECSCALE_R1%A #     V   a   WTPARVECSCALE_R1%X !   h  l      WTPARVECSCALE_R2 #   Ô  V   a   WTPARVECSCALE_R2%X #   *	  @   a   WTPARVECSCALE_R2%A !   j	  l      WTPARVECSCALE_Z1 #   Ö	  @   a   WTPARVECSCALE_Z1%A #   
  V   a   WTPARVECSCALE_Z1%X !   l
  l      WTPARVECSCALE_Z2 #   Ø
  V   a   WTPARVECSCALE_Z2%X #   .  @   a   WTPARVECSCALE_Z2%A    n  c      u@DOT #   Ñ  V       gen@WTPARCSRMATVEC !   '  n      WTPARCSRMATVEC_C )     V   a   WTPARCSRMATVEC_C%HPARCSR (   ë  V   a   WTPARCSRMATVEC_C%VEC_IN )   A  V   a   WTPARCSRMATVEC_C%VEC_OUT -            gen@WTPARVECSETCONSTANTVALUE +     |       gen@WTPARVECSETSINGLEVALUE )     d      WTPARVECSETSINGLEVALUE_R 0   ÷  V   a   WTPARVECSETSINGLEVALUE_R%PARVEC +   M  @   a   WTPARVECSETSINGLEVALUE_R%I -     @   a   WTPARVECSETSINGLEVALUE_R%VAL )   Í  d      WTPARVECSETSINGLEVALUE_Z 0   1  V   a   WTPARVECSETSINGLEVALUE_Z%PARVEC +     @   a   WTPARVECSETSINGLEVALUE_Z%I -   Ç  @   a   WTPARVECSETSINGLEVALUE_Z%VAL "     Í      WTPARCSRCOMM+WMPI '   Ô  H   a   WTPARCSRCOMM%COMM+WMPI +     H   a   WTPARCSRCOMM%NUMSENDS+WMPI +   d     a   WTPARCSRCOMM%SENDCPUS+WMPI 0   ø     a   WTPARCSRCOMM%SENDMAPSTARTS+WMPI 2        a   WTPARCSRCOMM%SENDMAPELEMENTS+WMPI +      H   a   WTPARCSRCOMM%NUMRECVS+WMPI +   h     a   WTPARCSRCOMM%RECVCPUS+WMPI 0   ü     a   WTPARCSRCOMM%RECVVECSTARTS+WMPI "           WTCOMMHANDLE+WMPI +   *  b   a   WTCOMMHANDLE%SENDRECV+WMPI -     H   a   WTCOMMHANDLE%NUMREQUEST+WMPI -   Ô     a   WTCOMMHANDLE%MPIREQUEST+WMPI +   h     a   WTCOMMHANDLE%SENDDATA+WMPI +   ü     a   WTCOMMHANDLE%RECVDATA+WMPI              WTCSR    0  H   a   WTCSR%NUMROWS    x  H   a   WTCSR%NUMCOLS "   À  H   a   WTCSR%NUMNONZEROS         a   WTCSR%ROWINDEX         a   WTCSR%IA    0     a   WTCSR%JA    Ä     a   WTCSR%A    X  í       WTPARCSR    E  H   a   WTPARCSR%COMM '     H   a   WTPARCSR%GLOBALNUMROWS '   Õ  H   a   WTPARCSR%GLOBALNUMCOLS %     H   a   WTPARCSR%NUMNONZEROS    e  [   a   WTPARCSR%DIAG    À  [   a   WTPARCSR%OFFD $        a   WTPARCSR%COLMAPOFFD #   ¯     a   WTPARCSR%ROWSTARTS #   C      a   WTPARCSR%COLSTARTS     ×   H   a   WTPARCSR%ISCOMM "   !  b   a   WTPARCSR%SENDRECV    !  f       WTSEQVEC     ç!  H   a   WTSEQVEC%LENGTH    /"     a   WTSEQVEC%DATA    Ã"         WTPARVEC    Z#  H   a   WTPARVEC%COMM &   ¢#  H   a   WTPARVEC%GLOBALLENGTH $   ê#  H   a   WTPARVEC%FIRSTINDEX #   2$  H   a   WTPARVEC%LASTINDEX     z$  ^   a   WTPARVEC%SEQVEC    Ø$  V       WTPARVECCOPY    .%  V   a   WTPARVECCOPY%Y    %  V   a   WTPARVECCOPY%X "   Ú%  b       WTPARVECINNERPROD &   <&  V   a   WTPARVECINNERPROD%BRA &   &  V   a   WTPARVECINNERPROD%KET .   è&  b       WTPARVECINNERPRODWITHNOREDUCE 2   J'  V   a   WTPARVECINNERPRODWITHNOREDUCE%BRA 2    '  V   a   WTPARVECINNERPRODWITHNOREDUCE%KET    ö'  @       MAXNUMNONZEROS     6(  x       CONVERTCOOTOCSR "   ®(  @   a   CONVERTCOOTOCSR%N $   î(  @   a   CONVERTCOOTOCSR%NNZ "   .)  ´   a   CONVERTCOOTOCSR%A #   â)  ´   a   CONVERTCOOTOCSR%IA #   *  ´   a   CONVERTCOOTOCSR%JA $   J+  &  a   CONVERTCOOTOCSR%IWK    p,  t       WTCSRCREATE "   ä,  @   a   WTCSRCREATE%NROWS "   $-  @   a   WTCSRCREATE%NCOLS #   d-  @   a   WTCSRCREATE%MAXNNZ !   ¤-  S   a   WTCSRCREATE%HCSR    ÷-  R       WTCSRDESTROY "   I.  S   a   WTCSRDESTROY%HCSR     .  R       WTCSRINITIALIZE %   î.  S   a   WTCSRINITIALIZE%HCSR    A/  ]       WTSEQVECCREATE &   /  @   a   WTSEQVECCREATE%LENGTH #   Þ/  V   a   WTSEQVECCREATE%VEC     40  Q       WTSEQVECDESTROY $   0  V   a   WTSEQVECDESTROY%VEC #   Û0  Q       WTSEQVECINITIALIZE '   ,1  V   a   WTSEQVECINITIALIZE%VEC    1  T       WTSEQVECPRINT %   Ö1  V   a   WTSEQVECPRINT%SEQVEC "   ,2  b       WTSEQVECINNERPROD &   2  V   a   WTSEQVECINNERPROD%BRA &   ä2  V   a   WTSEQVECINNERPROD%KET    :3  _       WTCSRTOPARCSR #   3  S   a   WTCSRTOPARCSR%HCSR &   ì3  V   a   WTCSRTOPARCSR%HPARCSR    B4  §       WTPARCSRCREATE $   é4  @   a   WTPARCSRCREATE%COMM )   )5     a   WTPARCSRCREATE%ROWSTARTS )   µ5     a   WTPARCSRCREATE%COLSTARTS /   A6  @   a   WTPARCSRCREATE%NUMNONZEROSDIAG /   6  @   a   WTPARCSRCREATE%NUMNONZEROSOFFD '   Á6  V   a   WTPARCSRCREATE%HPARCSR #   7  U       WTPARCSRINITIALIZE +   l7  V   a   WTPARCSRINITIALIZE%HPARCSR     Â7  U       WTPARCSRDESTROY (   8  V   a   WTPARCSRDESTROY%HPARCSR    m8  U       WTGENSENDRECV &   Â8  V   a   WTGENSENDRECV%HPARCSR "   9  V       WTSENDRECVDESTROY +   n9  Z   a   WTSENDRECVDESTROY%SENDRECV    È9  p       WTPARVECCREATE $   8:  @   a   WTPARVECCREATE%COMM ,   x:  @   a   WTPARVECCREATE%GLOBALLENGTH &   ¸:  V   a   WTPARVECCREATE%PARVEC     ;  T       WTPARVECDESTROY '   b;  V   a   WTPARVECDESTROY%PARVEC #   ¸;  T       WTPARVECINITIALIZE *   <  V   a   WTPARVECINITIALIZE%PARVEC    b<  T       WTPARVECPRINT %   ¶<  V   a   WTPARVECPRINT%PARVEC    =  W       WTPARVECNORM    c=  V   a   WTPARVECNORM%X    ¹=  ]       WTPARVECAXPY    >  @   a   WTPARVECAXPY%A    V>  V   a   WTPARVECAXPY%X    ¬>  V   a   WTPARVECAXPY%Y    ?  d       WTPARVECAXPBY     f?  @   a   WTPARVECAXPBY%A     ¦?  V   a   WTPARVECAXPBY%X     ü?  @   a   WTPARVECAXPBY%B     <@  V   a   WTPARVECAXPBY%Y "   @  O       WTPARVECNORMALIZE $   á@  V   a   WTPARVECNORMALIZE%X '   7A  c       WTPARVECGETSINGLEVALUE .   A  V   a   WTPARVECGETSINGLEVALUE%PARVEC )   ðA  @   a   WTPARVECGETSINGLEVALUE%I '   0B  T       WTPARVECSETRANDOMVALUE .   B  V   a   WTPARVECSETRANDOMVALUE%PARVEC $   ÚB  T       WTPARVECSETSEQVALUE +   .C  V   a   WTPARVECSETSEQVALUE%PARVEC %   C  _       WTPARCSRMATRIXCREATE *   ãC  @   a   WTPARCSRMATRIXCREATE%MDIM -   #D  V   a   WTPARCSRMATRIXCREATE%HPARCSR !   yD  ¦       CSR_SORT_INDICES #   E  @   a   CSR_SORT_INDICES%N %   _E  @   a   CSR_SORT_INDICES%NNZ $   E  &  a   CSR_SORT_INDICES%AP $   ÅF  ´   a   CSR_SORT_INDICES%AJ $   yG  ´   a   CSR_SORT_INDICES%AX #   -H         CSR_SUM_DUPLICATES %   »H  @   a   CSR_SUM_DUPLICATES%N '   ûH  @   a   CSR_SUM_DUPLICATES%NNZ &   ;I  &  a   CSR_SUM_DUPLICATES%IA &   aJ  ´   a   CSR_SUM_DUPLICATES%JA )   K  ´   a   CSR_SUM_DUPLICATES%A_VAL '   ÉK  é       ARPACK_SPARSE_COO_EIGS -   ²L  @   a   ARPACK_SPARSE_COO_EIGS%NDIMS .   òL  @   a   ARPACK_SPARSE_COO_EIGS%NNZMAX +   2M  @   a   ARPACK_SPARSE_COO_EIGS%NNZ ,   rM  ´   a   ARPACK_SPARSE_COO_EIGS%ACOO ,   &N  ´   a   ARPACK_SPARSE_COO_EIGS%JCOO ,   ÚN  ´   a   ARPACK_SPARSE_COO_EIGS%ICOO -   O  @   a   ARPACK_SPARSE_COO_EIGS%NEVAL -   ÎO  @   a   ARPACK_SPARSE_COO_EIGS%NVECS -   P  ´   a   ARPACK_SPARSE_COO_EIGS%DEVAL -   ÂP  @   a   ARPACK_SPARSE_COO_EIGS%SIGMA -   Q  $  a   ARPACK_SPARSE_COO_EIGS%ZEIGV /   &R  @   a   ARPACK_SPARSE_COO_EIGS%RITZVEC 