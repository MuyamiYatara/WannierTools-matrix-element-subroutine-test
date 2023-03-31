#if defined (INTELMKL)
    include 'mkl_dss.f90'
#endif

  module prec
     !>> A module controls the precision. 
     !> when the nnzmax is larger than 2,147,483,647 then li=8,
     !> otherwise, li=4. 
     !> warning: li=4 was tested, li=8 is not tested yet.
     integer,parameter :: li=4 ! long integer
     integer,parameter :: Dp=kind(1.0d0) ! double precision  
  end module prec

  module wmpi
     use prec

#if defined (MPI)
     include 'mpif.h'
#endif

     integer :: cpuid  ! CPU id for mpi
     integer :: num_cpu  ! Number of processors for mpi

#if defined (MPI)
     integer, parameter :: mpi_in= mpi_integer
     integer, parameter :: mpi_dp= mpi_double_precision
     integer, parameter :: mpi_dc= mpi_double_complex
     integer, parameter :: mpi_cmw= mpi_comm_world
#endif 

     !> Define a structure containing information for doing communication
     type WTParCSRComm
  
        !> mpi communicator
        integer :: comm
  
        !> how many cpus that we need to send data on
        integer :: NumSends
  
        !> which cpus that we need to send data on
        integer, pointer :: SendCPUs(:)
  
        !> when before we send the vector data to other cpus, we need to get the 
        !> data which should be sent, then put these data to a array called 
        !> x_buf_data(:). The array SendMapElements(:) gives the position of the 
        !> data in vector that should be sent.
        integer, pointer :: SendMapStarts(:)
  
        !> with this array, we can select the vector data that should be sent
        integer(li), pointer :: SendMapElements(:)
  
        !> How many cpus that we need to recieve data from
        integer :: NumRecvs
  
        !> Which cpus that we need to recieve data from
        integer, pointer :: RecvCPUs(:)
  
        !> When recieved data from other cpus, we need to arrange those data into 
        !> an array. The length of this 
        integer, pointer :: RecvVecStarts(:)
     end type WTParCSRComm
  
     !> Define a structure containing information for doing communication
     type WTParVecComm
  
        !> mpi communicator
        integer :: comm
  
        !> how many cpus that we need to send data on
        integer :: NumSends
  
        !> which cpus that we need to send data on
        integer, pointer :: SendCPUs(:)
  
        !> when before we send the vector data to other cpus, we need to get the 
        !> data which should be sent, then put these data to a array called 
        !> x_buf_data(:). The array SendMapElements(:) gives the position of the 
        !> data in vector that should be sent.
        integer, pointer :: RecvMapStarts(:)
  
        !> with this array, we can select the vector data that should be sent
        integer(li), pointer :: RecvMapElements(:)
  
        !> How many cpus that we need to recieve data from
        integer :: NumRecvs
  
        !> Which cpus that we need to recieve data from
        integer, pointer :: RecvCPUs(:)
  
        !> When recieved data from other cpus, we need to arrange those data into 
        !> an array. The length of this 
        integer, pointer :: SendVecStarts(:)
  
        integer :: NumRowsDiag
        integer :: NumRowsOffd
  
        integer(li), pointer :: RowMapOffd(:)
        integer(li), pointer :: LocalIndexOffd(:)
        integer(li), pointer :: LocalIndexDiag(:)
     end type WTParVecComm
  
  
  
     !> define a handle for comm, that can be created and destroyed
     type WTCommHandle
  
        type(WTParCSRComm), pointer :: sendrecv
  
        integer :: numrequest
        integer, pointer :: mpirequest(:)
        
        complex(dp), pointer :: senddata(:)
        complex(dp), pointer :: recvdata(:)
  
     end type WTCommHandle
  
     integer               :: BasisStart
     integer               :: BasisEnd
  
     contains
  
     !> generate partition for any vector with a given length 
     subroutine WTGeneratePartition(length, nprocs, part)

        implicit none

        integer(li), intent(in) :: length
        integer, intent(in) :: nprocs
        integer(li), intent(out) :: part(nprocs+1)
  
        integer :: i
        integer(li) :: div
        integer(li) :: mod1
  
        mod1= mod(length, nprocs)
        if (mod1.eq.0) then !< each cpu has the same load balance
           div= length/nprocs
           do i=0, nprocs-1
              part(i+1)=1+ i*div
           enddo
        else
           div= length/nprocs+ 1
           do i=0, nprocs
              if (i.ge. (nprocs-mod1)) then
                 part(i+1)= 1+ i*div- (nprocs-mod1)
              else
                 part(i+1)= 1+ i*(div-1) !< the main cpu will get smaller data
              endif
           enddo
        endif
        part(nprocs+1)= length+ 1
  
        return
     end subroutine WTGeneratePartition
  
     !> generate local partition for any vector with a given length 
     subroutine WTGenerateLocalPartition(length, nprocs, icpu, first, last)
        implicit none
        integer, intent(in) :: nprocs
        integer, intent(in) :: icpu
        integer(li), intent(in) :: length
        integer(li), intent(out) :: first
        integer(li), intent(out) :: last
  
        integer(li) :: div
        integer(li) :: mod1
  
        mod1= mod(length, nprocs)
        if (mod1.eq.0) then !< each cpu has the same load balance
           div= length/nprocs
           first=1+ icpu*div
           last=(1+ icpu)*div
        else
           div= length/nprocs+ 1
           if (icpu.ge. (nprocs-mod1)) then
              first= 1+ icpu*div- (nprocs-mod1)
              last= (1+ icpu)*div- (nprocs-mod1)
           else
              first= 1+ icpu*(div-1)
              last= (1+ icpu)*(div-1)!< the main cpu will get smaller data
           endif
        endif
  
        return
     end subroutine WTGenerateLocalPartition
  
     !> given the send data, recieve data and sendrecv list, we can use
     !> this subroutine to send and recieve data from other cpus.
     !> when finished this subroutine calls, we need call WTCommHandleDestroy
     !> to check whether the send recv operation is finished
     subroutine WTCommHandleCreate(SendRecv, SendData, RecvData, &
             CommHandle)
  
        implicit none
  
        !* in variables
        type(WTParCSRComm), intent(in), pointer :: SendRecv
        complex(dp), pointer :: SendData(:)
        complex(dp), pointer :: RecvData(:)
  
        !* out variables
        type(WTCommHandle), pointer :: CommHandle
  
        integer(li) :: VecStart
        integer(li) :: VecLen
  
        !> sendrecv data
        integer, pointer :: SendCPUs(:)
        integer, pointer :: SendMapStarts(:)
        integer(li), pointer :: SendMapElements(:)
        integer, pointer :: RecvCPUs(:)
        integer, pointer :: RecvVecStarts(:)
  
        integer :: NumRecvs
        integer :: NumSends
        integer :: NumRequest
        integer, pointer :: MpiRequest(:)
  
        integer :: ierr
        integer :: comm
        integer :: NCPUs
        integer :: cpu_id
  
        integer :: i, j
        integer :: icpu
  
        !* initialize null pointers
        SendCPUs=> Null()
        SendMapStarts=> Null()
        SendMapElements=> Null()
        RecvCPUs=> Null()
        RecvVecStarts=> Null()
        MpiRequest=> Null()
  
#if defined (MPI)
        comm= SendRecv%Comm
        call mpi_comm_size(comm, NCPUS, ierr)
        call mpi_comm_rank(comm, cpu_id, ierr)
#endif  
        NumSends= SendRecv%NumSends
        NumRecvs= SendRecv%NumRecvs
        NumRequest= NumSends+ NumRecvs
  
        SendCPUs=> SendRecv%SendCPUs
        SendMapStarts=> SendRecv%SendMapStarts
        SendMapElements=> SendRecv%SendMapElements
        RecvCPUs=> SendRecv%RecvCPUs
        RecvVecStarts=> SendRecv%RecvVecStarts
  
        MpiRequest=> Null()
        if (.not.associated(CommHandle)) allocate(CommHandle)
        allocate(CommHandle%MpiRequest(NumRequest))
        MpiRequest=> CommHandle%MpiRequest
  
        !> recieve data from other cpus using non-block communication
        j=1
        do i=1, NumRecvs
           icpu= RecvCPUs(i)
           VecStart= RecvVecStarts(i)
           VecLen= RecvVecStarts(i+1)- RecvVecStarts(i)
#if defined (MPI)
           call mpi_irecv(RecvData(VecStart), VecLen, mpi_dc, icpu, &
                          0, comm, MpiRequest(j), ierr)
#endif
           j=j+1
        enddo
  
        !> send data to other cpus using non-block communication
        do i=1, NumSends
           icpu= SendCPUs(i)
           VecStart= SendMapStarts(i)
           VecLen= SendMapStarts(i+1)- SendMapStarts(i)
#if defined (MPI)
           call mpi_isend(SendData(VecStart), VecLen, mpi_dc, icpu, &
                          0, comm, MpiRequest(j), ierr)
#endif
           j=j+1
        enddo
  
        CommHandle%NumRequest= NumRequest
        CommHandle%SendData=> SendData
        CommHandle%RecvData=> RecvData
        CommHandle%SendRecv=> SendRecv
  
        return
  
     end subroutine WTCommHandleCreate
  
     subroutine WTCommHandleDestroy(CommHandle)
  
        implicit none
  
        type(WTCommHandle), pointer :: CommHandle
  
        integer :: ierr
        integer :: NumRequest
        integer, pointer :: MpiRequest(:)
        integer, pointer :: MpiStatus(:)
  
        NumRequest= CommHandle%NumRequest
        MpiRequest=> CommHandle%MpiRequest
  
        if (.not.associated(CommHandle)) return
  
        if (NumRequest>0) then
#if defined (MPI)
           allocate(MpiStatus(mpi_status_size*NumRequest))
           call mpi_waitall(NumRequest, MpiRequest, MpiStatus, ierr)
#endif
        endif
  
        return
     end subroutine WTCommHandleDestroy
  
     !> define my mpi_allreduce for complex array
     subroutine mp_allreduce_z(comm, ndim, vec, vec_mpi)
        implicit none
  
        integer, intent(in) :: comm
        integer, intent(in) :: ndim
        complex(dp), intent(in) :: vec(ndim)
        complex(dp), intent(inout) :: vec_mpi(ndim)
  
        integer :: ierr
  
        vec_mpi= 0d0
  
#if defined (MPI)
        call mpi_allreduce(vec, vec_mpi, ndim, &
                           mpi_dc, mpi_sum, comm, ierr)
#else
        vec_mpi= vec
#endif
  
        return
     end subroutine mp_allreduce_z

  end module wmpi

  module para
     !> Some global parameters 
     !
     !> Copyright (c) 2010 QuanSheng Wu. All rights reserved.
     !
     !> add namelist for convenience  June 5th 2016 by QuanSheng Wu

     use wmpi
     use prec
     implicit none

     character(80) :: version

     integer,parameter :: stdout= 8

     type int_array1D
        integer :: length
        integer, allocatable :: iarray(:)
     end type int_array1D

     !> define the file index to void the same index in different subroutines
     integer, public, save :: outfileindex= 11932

     character(80) :: Hrfile
     character(80) :: Particle
     character(80) :: Package
     character(80) :: KPorTB
     real(dp) :: vef
     logical :: Is_Sparse_Hr, Is_Sparse, Use_ELPA, Is_Hrfile
     namelist / TB_FILE / Hrfile, Particle, Package, KPorTB, Is_Hrfile, Is_Sparse, Is_Sparse_Hr, Use_ELPA,vef

     !> control parameters
     logical :: BulkBand_calc    ! Flag for bulk energy band calculation
     logical :: BulkBand_line_calc    ! Flag for bulk energy band calculation
     logical :: BulkBand_unfold_line_calc    ! Flag for bulk energy band calculation
     logical :: BulkBand_unfold_plane_calc    ! Flag for bulk energy band calculation
     logical :: QPI_unfold_plane_calc    ! Flag for bulk energy band calculation
     logical :: Landaulevel_unfold_line_calc    ! Flag for bulk energy band calculation
     logical :: BulkFatBand_calc    ! Flag for bulk energy band calculation
     logical :: BulkBand_plane_calc    ! Flag for bulk energy band calculation for a fixed k plane 
     logical :: BulkBand_cube_calc    ! Flag for bulk energy band calculation for a fixed k plane 
     logical :: BulkBand_points_calc    ! Flag for bulk energy band calculation for some k points
     logical :: BulkFS_calc      ! Flag for bulk 3D fermi surface in 3D BZ calculation
     logical :: BulkFS_plane_calc ! Flag for bulk fermi surface for a fix k plane calculation
     logical :: BulkFS_plane_stack_calc ! Flag for bulk fermi surface for a fix k plane calculation
     logical :: BulkGap_cube_calc  ! Flag for Gap_cube calculation
     logical :: BulkGap_plane_calc ! Flag for Gap_plane calculation
     logical :: SlabBand_calc  ! Flag for 2D slab energy band calculation
     logical :: SlabBandWaveFunc_calc  ! Flag for 2D slab band wave function
     logical :: SlabBand_plane_calc  ! Flag for 2D slab energy band calculation
     logical :: WireBand_calc  ! Flag for 1D wire energy band calculation
     logical :: SlabSS_calc    ! Flag for surface state ARPES spectrum calculation
     logical :: Dos_calc       ! Flag for density of state calculation
     logical :: ChargeDensity_selected_bands_calc       ! Flag for charge density 
     logical :: ChargeDensity_selected_energies_calc       ! Flag for charge density 
     logical :: JDos_calc      ! Flag for joint density of state calculation
     logical :: SlabArc_calc   ! Flag for surface state fermi-arc calculation
     logical :: SlabQPI_calc   ! Flag for surface state QPI spectrum calculation in a given k plane in 2D BZ
     logical :: SlabQPI_kplane_calc  ! is the same as SlabQPI_calc
     logical :: SlabQPI_kpath_calc   ! Flag for surface state QPI spectrum calculation in a given kpath in 2D BZ
     logical :: SlabSpintexture_calc ! Flag for surface state spin-texture calculation
     logical :: BulkSpintexture_calc ! Flag for spin-texture calculation
     logical :: WannierCenter_calc  ! Flag for Wilson loop calculation
     logical :: Z2_3D_calc  ! Flag for Z2 number calculations of 6 planes
     logical :: WeylChirality_calc  ! Weyl chirality calculation
     logical :: NLChirality_calc  ! Chirality calculation for nodal line
     logical :: Chern_3D_calc  ! Flag for Chern number calculations of 6 planes
     logical :: MirrorChern_calc  ! Flag for mirror Chern number calculations
     logical :: BerryPhase_calc   ! Flag for Berry phase calculation
     logical :: BerryCurvature_calc ! Flag for Berry curvature calculation
     logical :: BerryCurvature_plane_selectedbands_calc ! Flag for Berry curvature calculation
     logical :: BerryCurvature_EF_calc ! Flag for Berry curvature calculation
     logical :: BerryCurvature_kpath_EF_calc ! Flag for Berry curvature calculation in kpath model at EF
     logical :: BerryCurvature_kpath_Occupied_calc ! Flag for Berry curvature calculation in kpath model sum over all occupied bands
     logical :: BerryCurvature_Cube_calc ! Flag for Berry curvature calculation
     logical :: BerryCurvature_slab_calc ! Flag for Berry curvature calculation for a slab system
     logical :: EffectiveMass_calc  ! Flag for effective mass calculation
     logical :: FindNodes_calc  ! Flag for effective mass calculation
     logical :: TBtoKP_calc  ! Flag for kp model construction from tight binding model
     logical :: Hof_Butt_calc  ! Flag for Hofstader butterfly
     logical :: LandauLevel_B_calc  ! Flag for Hofstader butterfly
     logical :: LOTO_correction  ! Flag for LOTO correction of phonon spectrum 
     logical :: Boltz_OHE_calc  ! Flag for Boltzmann tranport under magnetic field
     logical :: Boltz_Berry_correction  ! Flag for Boltzmann tranport under magnetic field
     logical :: Symmetry_Import_calc  ! Flag for Boltzmann tranport under magnetic field using symmetry
     logical :: Boltz_evolve_k  ! Flag for Boltzmann tranport under magnetic field
     logical :: Boltz_k_calc  ! Flag for Boltzmann tranport under magnetic field
     logical :: AHC_calc  ! Flag for Boltzmann tranport under magnetic field
     logical :: LandauLevel_k_calc  ! Flag for landau level calculation along k direction with fixed B
     logical :: LandauLevel_kplane_calc  ! Flag for landau level calculation along in a kplane in the magnetic BZ
     logical :: LandauLevel_k_dos_calc  ! Flag for landau level spectrum mode calculation along k direction with fixed B
     logical :: LandauLevel_B_dos_calc  ! Flag for landau level spectrum mode calculation for different B with given k point
     logical :: LandauLevel_wavefunction_calc  ! Flag for landau level calculation along k direction with fixed B
     logical :: OrbitalTexture_calc  ! Flag for Orbital texture calculation in a given k plane
     logical :: OrbitalTexture_3D_calc  ! Flag for Orbital texture calculation in a given k plane
     logical :: Fit_kp_calc  ! Flag for fitting kp model
     logical :: DMFT_MAG_calc  ! DMFT loop in uniform magnetic field
     logical :: LanczosSeqDOS_calc  ! DOS
     logical :: Translate_to_WS_calc  ! whether translate the k points into the Wigner-Seitz cell
     logical :: FermiLevel_calc  ! calculate Fermi level for a given temperature Beta=1/T
     
     logical :: LanczosBand_calc=.false.
     logical :: LanczosDos_calc= .false.
     logical :: landau_chern_calc = .false.
     logical :: export_newhr = .false.
     logical :: export_maghr =.false.
     
     logical :: w3d_nested_calc = .false.
     
     namelist / Control / BulkBand_calc, BulkFS_calc,  BulkFS_Plane_calc, &
                          BulkFS_plane_stack_calc,  BulkGap_plane_calc, &
                          QPI_unfold_plane_calc, &
                          BulkBand_unfold_line_calc, &
                          Landaulevel_unfold_line_calc, &
                          BulkBand_unfold_plane_calc, &
                          BulkBand_points_calc, BulkBand_cube_calc, BulkBand_line_calc, &
                          BulkGap_cube_calc, BulkSpintexture_calc,  BulkFatBand_calc, &
                          SlabBand_calc, SlabBand_plane_calc, SlabBandWaveFunc_calc,&
                          SlabQPI_calc, SlabQPI_kpath_calc, SlabQPI_kplane_calc, &
                          SlabSS_calc, SlabArc_calc, SlabSpintexture_calc,&
                          ChargeDensity_selected_bands_calc, &
                          ChargeDensity_selected_energies_calc, &
                          WireBand_calc, &
                          WannierCenter_calc,BerryPhase_calc, &
                          BerryCurvature_EF_calc, BerryCurvature_calc, &
                          Berrycurvature_kpath_EF_calc, BerryCurvature_kpath_Occupied_calc, &
                          BerryCurvature_plane_selectedbands_calc, &
                          BerryCurvature_slab_calc, MirrorChern_calc, BerryCurvature_Cube_calc, &
                          Z2_3D_calc, Chern_3D_calc, WeylChirality_calc, NLChirality_calc, &
                          Dos_calc, JDos_calc, EffectiveMass_calc, &
                          FindNodes_calc, TBtoKP_calc, LOTO_correction, &
                          BulkBand_plane_calc, Hof_Butt_calc, Symmetry_Import_calc, &
                          Boltz_Berry_correction, &
                          Boltz_k_calc, Boltz_evolve_k, Boltz_OHE_calc, AHC_Calc, &
                          LandauLevel_k_calc, OrbitalTexture_calc, OrbitalTexture_3D_calc, &
                          LandauLevel_wavefunction_calc, Fit_kp_calc, DMFT_MAG_calc, &
                          LanczosSeqDOS_calc, Translate_to_WS_calc, LandauLevel_k_dos_calc, &
                          LandauLevel_B_dos_calc,LanczosBand_calc,LanczosDos_calc, &
                          LandauLevel_B_calc, LandauLevel_kplane_calc,landau_chern_calc, &
                          FermiLevel_calc , export_newhr,export_maghr,w3d_nested_calc

     integer :: Nslab  ! Number of slabs for 2d Slab system
     integer :: Nslab1 ! Number of slabs for 1D wire system
     integer :: Nslab2 ! Number of slabs for 1D wire system

     integer :: Np !> Number of princple layers for surface green's function
     
     integer, public, save :: ijmax=10

     integer :: Ndim !> Leading dimension of surface green's function 

     integer :: Numoccupied !> Number of occupied bands for bulk unit cell
    

     real(dp) :: Ntotch !> Number of electrons
    
     integer :: Num_wann  ! Number of Wannier functions

     integer :: Nrpts ! Number of R points

   
     integer :: Nk   ! number of k points for different use
     integer :: Nk1  ! number of k points for different use
     integer :: Nk2  ! number of k points for different use
     integer :: Nk3  ! number of k points for different use
     integer, parameter :: Nk2_max= 4096   ! maximum number of k points 

     integer, public, save :: Nr1=5
     integer, public, save :: Nr2=5
     integer, public, save :: Nr3=2

   
     integer,parameter :: kmesh(2)=(/200 , 200/)  ! kmesh used for spintexture
     integer,parameter :: knv=kmesh(1)*kmesh(2)  ! number of k points used for spintexture


     integer :: Soc, SOC_in  ! A parameter to control soc;  Soc=0 means no spin-orbit coupling; Soc>0 means spin-orbit coupling

    
     real(Dp) :: eta     ! used to calculate dos epsilon+i eta
     real(Dp) :: Eta_Arc ! used to calculate dos epsilon+i eta

   
     integer :: OmegaNum   ! The number of energy slices between OmegaMin and OmegaMax
     integer :: OmegaNum_unfold   ! The number of energy slices between OmegaMin and OmegaMax
     real(dp), allocatable :: Omega_array(:)

     integer :: NumLCZVecs  !> number of Lanczos vectors
     integer :: NumSelectedEigenVals  !> number of Selected eigen values

     integer :: NumRandomConfs  !> number of random configurations, used in the Lanczos DOS calculation, default is 1

     real(dp) :: OmegaMin, OmegaMax ! omega interval 
  
     real(Dp) :: E_arc ! Fermi energy for arc calculation

   
     real(Dp) :: Gap_threshold  ! threshold value for output the the k points data for Gap3D

     !>> some parameters for DMFT
     !> The inverse of temperature Beta= 1/(KB*T), Beta*T=11600, T is in unit of Kelvin
     real(dp) :: Beta

     !> temperature related parameters, read from input.dat
     !> be used to define a range of temperatures, in units of Kelvin
     real(dp) :: Tmin
     real(dp) :: Tmax
     integer  :: NumT

     !> magnetic field times time in units of Tesla*ps
     real(dp) :: BTauMax, Relaxation_Time_Tau
     integer :: NBTau, BTauNum  
     integer :: Nslice_BTau_Max

     !> cut of radial for summation over R vectors
     real(dp) :: Rcut

     !> a integer to control the magnetic filed, Magp should smaller than Nq
     integer :: Magp, Magp_min, Magp_max, Magq

     !>> parameters for wilson loop calculation (Wannier charge center)

     !> the difference of the wilson loop between two neighbouring k points
     real(dp) :: wcc_neighbour_tol
     real(dp) :: wcc_calc_tol

     !> projection_weight_mode='UNFOLDEDKPOITNS', 'NORMAL'
     !> if project on the single K of another lattice, especially for twisted bilayer systems, 
     !> you have to specify the new lattice. For smaller new lattice, the bands will be unfolded
     !> for larger new lattice, the bands will be folded. 
     character(20) :: projection_weight_mode

     !> specify the atom index that located on the top surface that you want to study
     integer :: topsurface_atom_index
     real(dp) :: shift_to_topsurface_cart(3)

     !> namelist parameters
     namelist /PARAMETERS/ Eta_Arc, OmegaNum, OmegaNum_unfold, OmegaMin, OmegaMax, &
        E_arc, Nk1, Nk2, Nk3, NP, Gap_threshold, Tmin, Tmax, NumT, &
        NBTau, BTauNum, BTauMax, Rcut, Magp, Magq, Magp_min, Magp_max, Nslice_BTau_Max, &
        wcc_neighbour_tol, wcc_calc_tol, Beta,NumLCZVecs, &
        Relaxation_Time_Tau, &
        NumRandomConfs, NumSelectedEigenVals, projection_weight_mode, topsurface_atom_index
    
     real(Dp) :: E_fermi  ! Fermi energy, search E-fermi in OUTCAR for VASP, set to zero for Wien2k

     real(dp) :: surf_onsite  !> surface onsite energy shift
    
     real(dp) :: Bx, By, Bz !> magnetic field (in Tesla)
     real(dp) :: Btheta, Bphi !> magnetic field direction, Bx=cos(theta)*sin(phi), By=sin(theta)*sin(phi), Bz=cos(phi)
     real(dp) :: Bmagnitude  ! sqrt(Bx*Bx+By*By+Bz*Bz) in Tesla
     real(dp) :: Bdirection(3) !> a unit vector to represent the direction of B. 

     !> related to Zeeman effect, Zeeman energy =Effective_gfactor*Bohr_magneton*magneticfield
     !> eg. Effective_gfactor=2, magneticfield=1Tesla, then Zeeman_energy_in_eV =1.16*1E-4 eV  
     logical :: Add_Zeeman_Field  ! if consider zeeman effect in the tight binding model
     real(dp) :: Effective_gfactor ! in unit of Bohr magneton 
     real(dp), parameter :: Bohr_magneton= 0.5d0  ! in unit of Hatree atomic unit

     !> You can specify the Zeeman energy in unit of eV in the input.dat/wt.in directly
     !> or you can specify magnetic field and Effective_gfactor together
     !> But if you use Zeeman_energy_in_eV, you can't specify the direction
     real(dp) :: Zeeman_energy_in_eV

     !> Electric field along the stacking direction of a 2D system in eV/Angstrom
     real(dp) :: Electric_field_in_eVpA
     real(dp) :: Symmetrical_Electric_field_in_eVpA
     logical :: Inner_symmetrical_Electric_Field

     !> a parameter to control the Vacumm thickness for the slab system 
     !> only used for generating the POSCAR_slab
     real(dp) :: Vacuum_thickness_in_Angstrom

     !> system parameters namelist
     !> Some parameters that relate to the properties of the bulk hamiltonian
     namelist / SYSTEM / Soc, E_fermi, Bx, By, Bz, Btheta, Bphi, surf_onsite, &
        Nslab, Nslab1, Nslab2, Numoccupied, Ntotch, Bmagnitude, &
        Add_Zeeman_Field, Effective_gfactor, Zeeman_energy_in_eV, &
        Electric_field_in_eVpA, Symmetrical_Electric_field_in_eVpA, &
        Inner_symmetrical_Electric_Field, ijmax, &
        Vacuum_thickness_in_Angstrom

     real(dp),parameter :: alpha= 1.20736d0*1D-6  !> e/2/h*a*a   a=1d-10m, h is the planck constant then the flux equals alpha*B*s

     !> some parameters related to atomic units
     !> https://en.wikipedia.org/wiki/Hartree_atomic_units 2020
     !> WannierTools codes use Hatree atomic units
     real(dp),parameter :: Time_atomic=2.4188843265857E-17 ! atomic unit of time \hbar/E_Hatree
     real(dp),parameter :: Bohr_radius=5.29177210903E-11 ! Bohr radius in meters
     real(dp),parameter :: Angstrom2atomic=1d0/0.529177210903d0  ! Angstrom to atomic length unit (Bohr radius)
     real(dp),parameter :: Ang2Bohr=1d0/0.529177210903d0  ! Angstrom to atomic length unit (Bohr radius)
     real(dp),parameter :: eV2Hartree= 1d0/27.211385d0 ! electron Voltage to Hartree unit
     real(dp),parameter :: Echarge= 1.602176634E-19    ! electron charge in SI unit
     real(dp),parameter :: hbar= 1.054571817E-34    ! electron charge in SI unit
     real(dp),parameter :: epsilon0= 8.85418781762E-12    ! dielectric constant in SI unit
     real(dp),parameter :: Magneticfluxdensity_atomic=  2.35051756758*1E5    ! magnetic field strength in SI unit

     real(dp),parameter ::  Pi= 3.14159265358979d0  ! circumference ratio pi  
     real(dp),parameter :: half= 0.5d0  ! 1/2
     real(dp),parameter :: zero= 0.0d0  ! 0
     real(dp),parameter :: one = 1.0d0  ! 1
     real(dp),parameter :: eps3= 1e-3   ! 0.001
     real(dp),parameter :: eps4= 1e-4   ! 0.0001
     real(dp),parameter :: eps6= 1e-6   ! 0.000001
     real(dp),parameter :: eps8= 1e-8   ! 0.000001
     real(dp),parameter :: eps9= 1e-9   ! 0.000000001
     real(dp),parameter :: eps12= 1e-12   ! 0.000000000001
     complex(dp),parameter :: zzero= (0.0d0, 0d0)  ! 0

     real(Dp),parameter :: Ka(2)=(/1.0d0,0.0d0/)  
     real(Dp),parameter :: Kb(2)=(/0.0d0,1.0d0/)

     real(Dp),public, save :: Ra2(2)
     real(Dp),public, save :: Rb2(2)

     real(Dp),public, save :: Ka2(2)
     real(Dp),public, save :: Kb2(2)

     !> build a type for cell information
     type cell_type
        !> real space lattice vectors
        real(dp) :: Rua(3) ! Three vectors to define the cell box
        real(dp) :: Rub(3) 
        real(dp) :: Ruc(3) 
        real(dp) :: lattice(3, 3)

        !> a, b, c, alpha, beta, gamma
        real(dp) :: cell_parameters(6) 
        real(dp) :: reciprocal_cell_parameters(6) 

        !> reciprocal space lattice vectors
        real(dp) :: Kua(3)   ! three reciprocal primitive vectors
        real(dp) :: Kub(3)   ! three reciprocal primitive vectors
        real(dp) :: Kuc(3)   ! three reciprocal primitive vectors
        real(dp) :: reciprocal_lattice(3, 3)

        integer :: Num_atoms  ! number of atoms in one primitive cell
        integer :: Num_atom_type  ! number of atom's type in one primitive cell
        integer, allocatable :: Num_atoms_eachtype(:)  ! number of atoms for each atom's type in one primitive cell
        character(10), allocatable :: Name_of_atomtype(:)  ! type of atom  
        integer, allocatable :: itype_atom(:)  ! type of atom  
        character(10), allocatable :: Atom_name(:)  ! Atom's name
   
        real(dp) :: CellVolume ! Cell volume
        real(dp) :: ReciprocalCellVolume
   
        real(dp), allocatable :: Atom_position_cart(:, :)  ! Atom's cartesian position, only the atoms which have Wannier orbitals
        real(dp), allocatable :: Atom_position_direct(:, :)
        real(dp), allocatable :: wannier_centers_cart(:, :)
        real(dp), allocatable :: wannier_centers_direct(:, :)
        real(dp), allocatable :: Atom_magnetic_moment(:, :)  ! magnetic moment
   
        integer :: max_projs
        integer, allocatable :: nprojs(:) ! Number of projectors for each atoms
        integer :: NumberofSpinOrbitals
        integer, allocatable :: spinorbital_to_atom_index(:)
        integer, allocatable :: spinorbital_to_projector_index(:)
        character(10), allocatable :: proj_name(:, :) 
     end type cell_type

     type dense_tb_hr
        !> define a new type to describe the tight-binding Hamiltonian stored as 
        !> dense Wannier90 hr format 

        !> number of R lattice vector points
        integer :: nrpts

        !> R lattice vectors in units of three primitive lattice vectors
        integer, allocatable :: irvec(:, :)

        !> related cell
        type(cell_type) :: cell

        !> degenercy of R point induced by Wigner-Seitz cell integration
        integer, allocatable :: ndegen_R(:)

        !> Hamiltonian value
        complex(dp), allocatable :: HmnR(:, :, :)

     end type dense_tb_hr




     !> This is the main unit cell specified by user. 
     !> LATTICE, ATOM_POSITIONS, PROJECTORS
     type(cell_type) :: Origin_cell

     !> Usually, Fold_cell is smaller than Origin_cell. 
     type(cell_type) :: Folded_cell

     !> magnetic super cell after adding magnetic field, the size of it is Nslab.
     type(cell_type) :: Magnetic_cell

     !> A new cell defined by SURFACE card. 
     type(cell_type) :: Cell_defined_by_surface
     
     real(dp),public, save :: Rua_new(3) !> three primitive vectors in new coordinate system, see slab part
     real(dp),public, save :: Rub_new(3) !> three primitive vectors in new coordinate system, see slab part
     real(dp),public, save :: Ruc_new(3) !> three primitive vectors in new coordinate system, see slab part

     !> magnetic supercell
     real(dp),public, save :: Rua_mag(3) ! three  primitive vectors in Cartsien coordinatec
     real(dp),public, save :: Rub_mag(3) ! three  primitive vectors in Cartsien coordinatec
     real(dp),public, save :: Ruc_mag(3) ! three  primitive vectors in Cartsien coordinatec
    
     !> reciprocal lattice for magnetic supercell
     real(dp),public, save :: Kua_mag(3)   ! three reciprocal primitive vectors
     real(dp),public, save :: Kub_mag(3)   ! three reciprocal primitive vectors
     real(dp),public, save :: Kuc_mag(3)   ! three reciprocal primitive vectors

     real(dp),public, save :: Urot(3, 3)  ! Rotate matrix for the new primitve cell 

     ! k list for 3D case band
     integer :: nk3lines  ! Howmany k lines for bulk band calculation
     integer :: nk3_band  ! Howmany k points for each k line
     character(4), allocatable :: k3line_name(:) ! Name of the K points
     real(dp),allocatable :: k3line_stop(:)  ! Connet points
     real(dp),allocatable :: k3line_start(:, :) ! Start point for each k line
     real(dp),allocatable :: k3line_end(:, :) ! End point for each k line
     real(dp),allocatable :: K3list_band(:, :) ! coordinate of k points for bulk band calculation in kpath mode
     real(dp),allocatable :: K3len(:)  ! put all k points in a line in order to plot the bands 
     real(dp),allocatable :: K3points(:, :) ! coordinate of k points for bulk band calculation in cube mode

     !> k points in the point mode 
     integer :: Nk3_point_mode
     real(dp), allocatable :: k3points_pointmode_cart(:, :)
     real(dp), allocatable :: k3points_pointmode_direct(:, :)

     !> k points in unfolded BZ in the point mode 
     !> sometimes is used for projection
     integer :: Nk3_unfold_point_mode
     real(dp), allocatable :: k3points_unfold_pointmode_cart(:, :)
     real(dp), allocatable :: k3points_unfold_pointmode_direct(:, :)

     !> kpath for unfold supercell
     real(dp),allocatable :: K3len_unfold(:)  ! put all k points in a line in order to plot the bands 
     real(dp),allocatable :: k3line_unfold_stop(:)  ! Connet points



     !> kpath for magnetic supercell
     real(dp),allocatable :: K3len_mag(:)  ! put all k points in a line in order to plot the bands 
     real(dp),allocatable :: k3line_mag_stop(:)  ! Connet points

     ! k path for berry phase, read from the input.dat
     ! in the KPATH_BERRY card
     integer :: NK_Berry
     character(10) :: DirectOrCart_Berry ! Whether direct coordinates or Cartisen coordinates
     real(dp), allocatable :: k3points_Berry(:, :) ! only in direct coordinates

     !>> top surface atoms
     integer :: NtopAtoms, NtopOrbitals  ! Select atoms on the top surface for surface state output
     integer, allocatable :: TopAtoms(:)  ! Select atoms on the top surface for surface state output
     integer, allocatable :: TopOrbitals(:)  ! Orbitals on the top surface for surface state output

     !>> bottom surface atoms
     integer :: NBottomAtoms, NBottomOrbitals ! Select atoms on the bottom  surface for surface state output
     integer, allocatable :: BottomAtoms(:) ! Select atoms on the bottom  surface for surface state output
     integer, allocatable :: BottomOrbitals(:) ! Orbitals on the bottom  surface for surface state output

     !>> effective mass
     real(dp), public, save :: dk_mass  ! k step for effective mass calculation
     integer , public, save :: iband_mass   ! the i'th band for effective mass calculation
     real(dp), public, save :: k_mass(3) ! the k point for effective mass calculation

     !>  klist for 2D case include all 2D system
     integer :: nk2lines  ! Number of k lines for 2D slab band calculation
     integer :: knv2 ! Number of k points for each k line
     real(dp) :: kp(2, 32) ! start k point for each k line
     real(dp) :: ke(2, 32) ! end k point for each k line
     real(dp) :: k2line_stop(32)
     character(4) :: k2line_name(32)
     real(dp),allocatable :: k2len(:)
     real(dp),allocatable :: k2_path(:, :)

     !> A kpoint for 3D system--> only one k point
     real(dp), public, save :: Kpoint_3D_direct(3) ! the k point for effective mass calculation
     real(dp), public, save :: Kpoint_3D_cart(3) ! the k point for effective mass calculation
     
     character(10) :: DirectOrCart_SINGLE ! Whether direct coordinates or Cartisen coordinates
     real(dp), public, save :: Single_KPOINT_3D_DIRECT(3) ! the k point for effective mass calculation
     real(dp), public, save :: Single_KPOINT_3D_CART(3) ! the k point for effective mass calculation
     real(dp), public, save :: Single_KPOINT_2D_DIRECT(2) ! a single k point in the 2D slab BZ
     real(dp), public, save :: Single_KPOINT_2D_CART(2) 

     !> kpoints plane for 2D system--> arcs  
     real(dp) :: K2D_start(2)   ! start k point for 2D system calculation, like arcs
     real(dp) :: K2D_vec1(2) ! the 1st k vector for the k plane
     real(dp) :: K2D_vec2(2) ! the 2nd k vector for the k plane

     !> kpoints plane for 3D system --> gapshape
     real(dp) :: K3D_start(3) ! the start k point for the 3D k plane
     real(dp) :: K3D_vec1(3) ! the 1st k vector for the 3D k plane
     real(dp) :: K3D_vec2(3) ! the 2nd k vector for the 3D k plane
     real(dp) :: K3D_vec3(3)

     !> kpoints plane for 3D system --> gapshape3D
     real(dp) :: K3D_start_cube(3) ! the start k point for the k cube
     real(dp) :: K3D_vec1_cube(3) ! the 1st k vector for the k cube
     real(dp) :: K3D_vec2_cube(3) ! the 2nd k vector for the k cube
     real(dp) :: K3D_vec3_cube(3) ! the 3rd k vector for the k cube

     integer, allocatable     :: irvec(:,:)   ! R coordinates in fractional units
     real(dp), allocatable    :: crvec(:,:)   ! R coordinates in Cartesian coordinates in units of Angstrom
     complex(dp), allocatable :: HmnR(:,:,:)   ! Hamiltonian m,n are band indexes
     
     
     !sparse HmnR arraies
     integer,allocatable :: hicoo(:),hjcoo(:),hirv(:)
     complex(dp),allocatable :: hacoo(:)

     !> sparse hr length
     integer :: splen, splen_input
     
     
     integer, allocatable     :: ndegen(:)  ! degree of degeneracy of R point

     complex(dp), allocatable :: HmnR_newcell(:,:,:)   ! Hamiltonian m,n are band indexes
     real(dp), allocatable :: Atom_position_cart_newcell(:,:)   ! Hamiltonian m,n are band indexes
     real(dp), allocatable :: Atom_position_direct_newcell(:,:)   ! Hamiltonian m,n are band indexes
     integer, allocatable     :: irvec_newcell(:,:)   ! R coordinates
     integer, allocatable     :: ndegen_newcell(:)  ! degree of degeneracy of R point
     real(dp),public, save :: Rua_newcell(3) !> three rotated primitive vectors in old coordinate system
     real(dp),public, save :: Rub_newcell(3) !> three rotated primitive vectors in old coordinate system
     real(dp),public, save :: Ruc_newcell(3) !> three rotated primitive vectors in old coordinate system
     real(dp),public, save :: Kua_newcell(3)   ! three reciprocal primitive vectors, a
     real(dp),public, save :: Kub_newcell(3)   ! three reciprocal primitive vectors, b
     real(dp),public, save :: Kuc_newcell(3)   ! three reciprocal primitive vectors, c
 
     complex(dp),parameter    :: zi=(0.0d0, 1.0d0)    ! complex constant 0+1*i
     complex(dp),parameter    :: pi2zi=(0.0d0, 6.283185307179586d0) ! 2*pi*zi

     !> define surface
     real(dp), public, save :: Umatrix(3, 3)    ! a matrix change old primitive cell to new primitive cell which can define new surface, it is a 3*3 matrix
     integer, public, save :: MillerIndices(3)    ! a matrix change old primitive cell to new primitive cell which can define new surface, it is a 3*3 matrix

     character(10) :: AngOrBohr  ! Angstrom unit to Bohr unit
     character(10) :: DirectOrCart ! Whether direct coordinates or Cartisen coordinates
     real(dp) :: MagneticSuperCellVolume ! Cell volume
     real(dp) :: MagneticSuperProjectedArea !Projected area respect to the first vector specifed in SURFACE card in Angstrom^2
     real(dp) :: kCubeVolume
     real(dp) :: MagneticReciprocalCellVolume

     !> the start index for each atoms, only consider the spinless component
     integer, allocatable :: orbitals_start(:)

     !> symmetry operator apply on function basis
     complex(dp), allocatable :: inversion(:, :)
     complex(dp), allocatable :: mirror_x(:, :)
     complex(dp), allocatable :: mirror_y(:, :)
     complex(dp), allocatable :: mirror_z(:, :)
     complex(dp), allocatable :: C2yT(:, :)
     complex(dp), allocatable :: glide(:, :)
     
     !> symmetry operator apply on coordinate system
     real(dp), allocatable :: inv_op(:, :)
     real(dp), allocatable :: mirror_z_op(:, :)
     real(dp), allocatable :: mirror_x_op(:, :)
     real(dp), allocatable :: mirror_y_op(:, :)
     real(dp), allocatable :: glide_y_op(:, :)

     !> weyl point information from the input.dat
     integer :: Num_Weyls
     character(10) :: DirectOrCart_Weyl   ! Whether direct coordinates or Cartisen coordinates
     real(dp) :: kr0
     real(dp), allocatable :: weyl_position_cart(:, :)
     real(dp), allocatable :: weyl_position_direct(:, :)

     !> nodal loop information from the input.dat
     integer :: Num_NLs
     character(10) :: DirectOrCart_NL   ! Whether direct coordinates or Cartisen coordinates
     real(dp) :: Rbig_NL
     real(dp) :: rsmall_a_NL, rsmall_b_NL
     real(dp), allocatable :: NL_center_position_cart(:, :)
     real(dp), allocatable :: NL_center_position_direct(:, :)


     !> parameters for tbtokp
     integer :: Num_selectedbands_tbtokp
     integer, allocatable :: Selected_bands_tbtokp(:)
     real(dp) :: k_tbtokp(3)   ! The K point that used to construct kp model


     !> for phonon LO-TO correction. By T.T Zhang
     real(dp), public, save :: Diele_Tensor(3, 3) ! di-electric tensor
     real(dp), allocatable :: Born_Charge(:, :, :)
     real(dp), allocatable :: Atom_Mass(:)

     real(dp), parameter :: VASPToTHZ= 29.54263748d0 ! By T.T zhang

     type kcube_type
        !> define a module for k points in BZ in purpose of MPI 
    
        integer :: Nk_total
        integer :: Nk_current
        integer :: Nk_start
        integer :: Nk_end
        integer, allocatable  :: ik_array(:)
        integer, allocatable  :: IKleft_array(:)

        real(dp), allocatable :: Ek_local(:)
        real(dp), allocatable :: Ek_total(:)
        real(dp), allocatable :: k_direct(:, :)
        real(dp), allocatable :: weight_k(:)

        !> velocities
        real(dp), allocatable :: vx_local(:)
        real(dp), allocatable :: vx_total(:)
        real(dp), allocatable :: vy_local(:)
        real(dp), allocatable :: vy_total(:)
        real(dp), allocatable :: vz_local(:)
        real(dp), allocatable :: vz_total(:)
        real(dp), allocatable :: weight_k_local(:)
     end type kcube_type

     type(kcube_type) :: KCube3D

     !> gather the reduced k points and the original k points
     type kcube_type_symm
        !> Nk1*Nk2*Nk3
        integer :: Nk_total
        !> total number of reduced k points
        integer :: Nk_total_symm
        !> relate the full kmesh to the reduced k point
        integer, allocatable :: ik_relate(:)
        !> reduced k points
        integer, allocatable :: ik_array_symm(:)
        real(dp), allocatable :: weight_k(:)
     end type kcube_type_symm

     type(kcube_type_symm) :: KCube3D_symm

     !> Select those atoms which used in the construction of the Wannier functions
     !> It can be useful when calculate the projected weight related properties
     !> such as the surface state, slab energy bands.
     integer :: NumberofSelectedAtoms_groups
     type(int_array1D), allocatable :: Selected_Atoms(:)
     integer, allocatable :: NumberofSelectedAtoms(:)

     !> selected wannier orbitals 
     !> this part can be read from the input.dat or wt.in file
     !> if not specified in the input.dat or wt.in, we will try to specify it from  the
     !> SelectedAtoms part. 
     integer :: NumberofSelectedOrbitals_groups
     integer, allocatable :: NumberofSelectedOrbitals(:)
     type(int_array1D), allocatable :: Selected_WannierOrbitals(:)

     !> selected bands for magnetoresistance
     integer :: NumberofSelectedBands
     integer, allocatable :: Selected_band_index(:)

     !> selected occupied bands for wannier charge center(Wilson loop) calculation
     !> the bands should be continous 
     integer :: NumberofSelectedOccupiedBands
     integer, allocatable :: Selected_Occupiedband_index(:)

     !> index for non-spin polarization 
     integer, allocatable :: index_start(:)
     integer, allocatable :: index_end(:)

     !> time 
     character(8)  :: date_now
     character(10) :: time_now
     character(5)  :: zone_now

     !> total number of symmetry operators in the system
     integer :: number_group_generators
     integer :: number_group_operators

     !> point group generator operation defined by the BasicOperations_space
     integer , allocatable :: generators_find(:)

     !> translation operator generators in fractional/direct coordinate
     real(dp), allocatable :: tau_find(:,:)

     !> point group operators in cartesian and direct coordinate
     real(dp), allocatable :: pggen_cart(:, :, :)
     real(dp), allocatable :: pggen_direct(:, :, :)

     !> space group operators in cartesian and direct coordinate
     real(dp), allocatable :: pgop_cart(:, :, :)
     real(dp), allocatable :: pgop_direct(:, :, :)
     real(dp), allocatable :: tau_cart(:,:)
     real(dp), allocatable :: tau_direct(:,:)
     real(dp), allocatable :: spatial_inversion(:)


 end module para


 module wcc_module
    ! module for Wannier charge center (Wilson loop) calculations.
    use para
    implicit none

    
    type kline_wcc_type
       ! define a type of all properties at the k point to get the wcc
       real(dp) :: k(3)  ! coordinate
       real(dp) :: delta ! apart from the start point
       real(dp), allocatable :: wcc(:)  ! 1:Numoccupied, wannier charge center
       real(dp), allocatable :: gap(:)  ! 1:Numoccupied, the distance between  wcc neighbours
       real(dp) :: largestgap_pos_i     ! largest gap position
       real(dp) :: largestgap_pos_val   ! largest gap position value
       real(dp) :: largestgap_val       ! largest gap value
       logical  :: converged            ! converged or not 
       logical  :: calculated
    end type kline_wcc_type

    type kline_integrate_type
       ! define a type of all properties at the k point for integration
       real(dp) :: k(3)  ! coordinate
       real(dp) :: delta ! apart from the start point
       real(dp) :: b(3)  ! dis
       logical  :: calculated
       ! We only store the eigenvectors of the occupied states
       complex(dp), allocatable :: eig_vec(:, :)  !dim= (num_wann, NumOccupied)
    end type kline_integrate_type

 end module wcc_module



 !> information from periodic element table stored in one module
module element_table
   use para, only: dp, pi, zi
   
   implicit none
   
   integer, parameter :: lenth_of_table = 104 ! number of elements in this table
   integer, parameter :: lines_of_table = 7 ! the number of lines in the table
   integer, parameter :: angular_number = 4 ! the number of angular orbitals that we considered
   integer, parameter :: magnetic_number_max = 7 ! the max number of orbitals with different magnetic number
   real, parameter :: a_0 = 5.29177210903E-1 ! Bohr radius in the unit of angstrom
   
   
   character(len=10) :: element_name(lenth_of_table) = ['H','He','Li','Be','B','C','N','O','F','Ne','Na','Mg','Al','Si','P','S','Cl','Ar','K','Ca','Sc','Ti','V','Cr','Mn','Fe','Co','Ni','Cu','Zn','Ga','Ge','As','Se','Br','Kr','Rb','Sr','Y','Zr','Nb','Mo','Tc','Ru','Rh','Pd','Ag','Cd','In','Sn','Sb','Te','I','Xe','Cs','Ba','La','Ce','Pr','Nd','Pm','Sm','Eu','Gd','Tb','Dy','Ho','Er','Tm','Yb','Lu','Hf','Ta','W','Re','Os','Ir','Pt','Au','Hg','Tl','Pb','Bi','Po','At','Rn','Fr','Ra','Ac','Th','Pa','U','Np','Pu','Am','Cm','Bk','Cf','Es','Fm','Md','No','Lr','Rf']

   ! each element's electron configuration
   character(len=64) :: element_electron_config(lenth_of_table) = [&
   '1s1'&
   ,'1s2'&
   ,'1s22s1'&
   ,'1s22s2'&
   ,'1s22s22p1'&
   ,'1s22s22p2'&
   ,'1s22s22p3'&
   ,'1s22s22p4'&
   ,'1s22s22p5'&
   ,'1s22s22p6'&
   ,'1s22s22p63s1'&
   ,'1s22s22p63s2'&
   ,'1s22s22p63s23p1'&
   ,'1s22s22p63s23p2'&
   ,'1s22s22p63s23p3'&
   ,'1s22s22p63s23p4'&
   ,'1s22s22p63s23p5'&
   ,'1s22s22p63s23p6'&
   ,'1s22s22p63s23p64s1'&
   ,'1s22s22p63s23p64s2'&
   ,'1s22s22p63s23p63d14s2'&
   ,'1s22s22p63s23p63d24s2'&
   ,'1s22s22p63s23p63d34s2'&
   ,'1s22s22p63s23p63d54s1'&
   ,'1s22s22p63s23p63d54s2'&
   ,'1s22s22p63s23p63d64s2'&
   ,'1s22s22p63s23p63d74s2'&
   ,'1s22s22p63s23p63d84s2'&
   ,'1s22s22p63s23p63d104s1'&
   ,'1s22s22p63s23p63d104s2'&
   ,'1s22s22p63s23p63d104s24p1'&
   ,'1s22s22p63s23p63d104s24p2'&
   ,'1s22s22p63s23p63d104s24p3'&
   ,'1s22s22p63s23p63d104s24p4'&
   ,'1s22s22p63s23p63d104s24p5'&
   ,'1s22s22p63s23p63d104s24p6'&
   ,'1s22s22p63s23p63d104s24p65s1'&
   ,'1s22s22p63s23p63d104s24p65s2'&
   ,'1s22s22p63s23p63d104s24p64d15s2'&
   ,'1s22s22p63s23p63d104s24p64d25s2'&
   ,'1s22s22p63s23p63d104s24p64d45s1'&
   ,'1s22s22p63s23p63d104s24p64d55s1'&
   ,'1s22s22p63s23p63d104s24p64d55s2'&
   ,'1s22s22p63s23p63d104s24p64d75s1'&
   ,'1s22s22p63s23p63d104s24p64d85s1'&
   ,'1s22s22p63s23p63d104s24p64d10'&
   ,'1s22s22p63s23p63d104s24p64d105s1'&
   ,'1s22s22p63s23p63d104s24p64d105s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p1'&
   ,'1s22s22p63s23p63d104s24p64d105s25p2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p3'&
   ,'1s22s22p63s23p63d104s24p64d105s25p4'&
   ,'1s22s22p63s23p63d104s24p64d105s25p5'&
   ,'1s22s22p63s23p63d104s24p64d105s25p6'&
   ,'1s22s22p63s23p63d104s24p64d105s25p66s1'&
   ,'1s22s22p63s23p63d104s24p64d105s25p66s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p65d16s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f15d16s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f36s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f46s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f56s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f66s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f76s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f75d16s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f96s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f106s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f116s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f126s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f136s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f146s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d16s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d26s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d36s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d46s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d56s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d66s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d76s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d96s1'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s1'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p1'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p3'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p4'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p5'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p6'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p67s1'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p67s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p66d17s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p66d27s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p65f26d17s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p65f36d17s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p65f46d17s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p65f67s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p65f77s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p65f76d17s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p65f97s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p65f107s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p65f117s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p65f127s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p65f137s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p65f147s2'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p65f147s27p1'&
   ,'1s22s22p63s23p63d104s24p64d105s25p64f145d106s26p65f146d27s2']

   character :: orb_ang_sign(angular_number) = ['s','p','d','f'] ! angular signs of orbital, only "spdf" are included
   character(10) :: orb_sign(magnetic_number_max, angular_number) = &
   [['','','','s','','',''],&
   ['','','py','pz','px','',''],&
   ['','dxy','dyz','dz2','dxz','dx2-y2',''],&
   ['fy(3x2-y2)','fxyz','fyz2','fz3','fxz2','fz(x2-y2)','fx(x2-3y2)']]
   
contains

   !> Find the specific element's index
   subroutine get_element_index(name, index_)
       
       character(len=10), intent(in) :: name ! the element we want to know its index

       integer :: index_
       integer :: i
       
       index_ = 0
       !write(*,*) element_name
       do i = 1, size(element_name)
           if ( element_name(i) == name ) then
               index_ = i
               exit                
           end if
       end do

       if ( index_ == 0 )  write(*,*) "Element is not in this table !"

   end subroutine get_element_index
   
   !> Find the specific orbital's l,m
   subroutine get_orbital_index(orbital_name,  index_l, index_m)
     
       implicit none
       character(10), intent(in) :: orbital_name

       integer :: index_l  
       integer :: index_m 
       integer :: i, j
       
       index_l = -1
       index_m = 0
       do i = 1, magnetic_number_max
           do j = 1, angular_number
               if(orbital_name == orb_sign(i,j)) then
                   index_m = i-angular_number
                   index_l = j-1
                   !write(*,*) i, j
                   exit
               end if
           end do
       end do

       if (index_l == -1) then
           write(*,*) "Orbital is not in this table !"
       end if

   end subroutine get_orbital_index



   !> Get specific element's extranuclear electron arrangement
   subroutine get_electron_config(name, configuration)

       implicit none
       
       character(len=10), intent(in) :: name
       integer ::  configuration(lines_of_table,angular_number) 
       ! we now consider all the electrons have pricipal quantum number n<7 
       ! and angular quantum number l<4
       
       integer :: index_ 
       integer :: n ! principal quantum number , also the first index of configuration
       character(len=64) :: config_temporary,orbital_temporary ! save the single element's configuration and
                                                               ! orbital information temporarily
       integer :: j,k,ifst,isec

       call get_element_index(name , index_)
       config_temporary = element_electron_config(index_)
       
       configuration = 0
       do while(.True.)
           if (len(trim(config_temporary)) == 0 )exit
           
               !> get one specific orbital's name first
               ifst = 1 + 1
               isec = len(trim(config_temporary)) + 2
               findfirstorbital: do j = 1, len(trim(config_temporary))
                   do k = 1, size(orb_ang_sign)
                       if(orb_ang_sign(k) == config_temporary(j:j)) then
                           ifst = j
                           exit findfirstorbital !when get one orbital jump out of the cycle instantly 
                       end if
                   end do ! first k loop
               end do findfirstorbital! first j loop
               
               !>then get the second orbital beside the first nearestly
               findnextorbital:do j = (ifst + 1) , len(trim(config_temporary))
                   do k = 1, size(orb_ang_sign)
                       
                       if(orb_ang_sign(k) == config_temporary(j:j)) then
                           isec = j
                           exit findnextorbital
                       end if
                   end do ! second k loop
               end do findnextorbital! second j loop
               

               orbital_temporary = config_temporary((ifst - 1) :(isec - 2))
               config_temporary = config_temporary((isec - 1):)

               !> then we try to pick up the number of electrons on this orbital
               read(orbital_temporary(1:1),'(I4)') n
               do k = 1,size(orb_ang_sign)
                   if (orbital_temporary(2:2) == orb_ang_sign(k)) read(orbital_temporary(3:),'(I8)') configuration(n,k) 

               end do 
           
       end do

   end subroutine get_electron_config


   !> Get the valence electrons' configuration of a specific element
   subroutine get_valence_config(name, v_configuration )
       implicit none
       
       character(len=10), intent(in) :: name
       integer ::  v_configuration(lines_of_table,angular_number) 
       ! we now consider all the electrons have pricipal quantum number n<7 and angular quantum number l<4
       ! only the valence electrons considered 

       integer ::  configuration(lines_of_table,angular_number)
       integer ::  Rgas_configuration(lines_of_table,angular_number)
       integer ::  Rgas(6) = [2,10,18,36,54,86] ! rare gases' atomic numbers

       integer :: i, Rgas_nearest, id

       call get_element_index(name,id)
       Rgas_nearest = 0
       do i = 1 , size(Rgas)
           if (Rgas(i) .GE. id) exit
           Rgas_nearest = i
       end do 

       configuration = 0
       Rgas_configuration = 0
       call get_electron_config(name , configuration)
       if(Rgas_nearest >0) call get_electron_config(element_name(Rgas(Rgas_nearest)) , Rgas_configuration)
       v_configuration = configuration - Rgas_configuration
       
   end subroutine get_valence_config
   
   
   !> Factorial calculation
   subroutine factorial(n,  res)
       integer, intent(in) :: n
       integer, intent(out) ::  res

       integer :: i
       
       res = 1
       if(n==0) then
           res = 1
           return
       else
           do i = 1, n
               res = res*i
           end do
       end if 
       
   end subroutine factorial

end module element_table

!> We use meters as the unit of lenth here, when positions are inputted, they must in the unit of meters !!!

module me_calculate
   use element_table
   
   implicit none
   integer :: p_num = 200 ! how many sections we divide the integrate interval into
   real(dp) :: inte_b = 50d0! the integral upper limit we start from to approach infinity
   real(dp) :: convergence_delta = 0.001d0 ! the convergence condition, when the integral result comes to slow down to a extent
   real(dp) :: inte_step = 10d0! step lenth when approaching infinity
   
   contains

   !> This subroutine is used to calculate the effective nuclear charge number Z_eff under slater rules
   subroutine Z_eff_cal(name, n, l, Z_eff)
       

       implicit none
       character(len=10) ,intent(in) :: name
       integer, intent(in) :: n ! the pricipal quantum number of the electron we are interested in 
       integer, intent(in) :: l ! the angular quantum number

       real(dp) :: Z_eff, sigma ! sigma is the shielding factor Z_eff = Z - sigma
       integer :: id ! element atomic number
       integer :: total_config(lines_of_table,angular_number) ! the total electron configuration of this element


       integer :: i,j,flag ! posi is the group number of the electron we are interested in 
       !integer :: slater_groups(16) ! we classify these electrons under slater rules ,then stored the results in slater_groups
                                   ! lenth can be longer if we consider more orbitals ,but currently it is enough to set 16
       
       call get_element_index(name , id)
       call get_electron_config(name , total_config)
       !write(*,*) id  

       !> check if the input n,l correspond to orbital empty
       if(total_config(n,(l+1))==0) then
           write(*,*) "there are no electrons on this orbital"
           return
       end if


       sigma = 0d0
       flag = 0


       !write(*,*) total_config ! test
       !write(*,*) posi

       if (n == 1 .and. l == 0) then
           sigma = 0.3d0
           flag = -1
       end if 

       if (flag /= -1) then
           if ( l == 0 .or. l == 1 ) then 
               ! slater rules , if electron we consider is on s or p orbital , the other electrons in the same
               ! group shield 0.35 , the electrons in n-1 group shield 0.85 , the electrons in n-2 or less than
               ! n-2 groups shield 1.00
               do i = 1 , n
                   !write(*,*) sigma
                   if(i<(n-1)) then
                       do j = 1, angular_number
                           sigma = sigma + 1d0*total_config(i,j)
                       end do
                   else if(i == (n-1)) then
                       do j = 1, angular_number
                           sigma = sigma + 0.85d0*total_config(i,j)
                       end do
                       
                   else if(i == n) then
                       do j = 1, 2
                           if(j == (l+1)) then
                               sigma = sigma + 0.35d0*(total_config(i,j)-1)
                           else
                               sigma = sigma + 0.35d0*(total_config(i,j))
                           end if
                       end do
                       
                   end if
               end do

           else if (l == 2 .or. l == 3) then
               !slater rules , if electron we consider is on d or f orbital , the other electrons in the same
               !group shield 0.35 , the electrons in n-1 or less than n-1 groups shield 1.00
                                           
               do i = 1 , n
                   !write(*,*) sigma
                   if(i<n) then
                       do j = 1, angular_number
                           sigma = sigma + 1d0*total_config(i,j)
                       end do
                   else if(i == n) then
                       do j = 1, angular_number
                           if(j == (l+1)) then
                               sigma = sigma + 0.35d0*(total_config(i,j)-1)
                           else
                               sigma = sigma + 1d0*(total_config(i,j))
                           end if
                       end do
                   end if
               end do
       
           else 
               write(*,*) "the value of l is wrong"
           end if
       end if ! first if

       Z_eff = 1d0*id - sigma

       !write(*,*) Z_eff , sigma

   end subroutine Z_eff_cal



   !> This subroutine is used for generating Slater-type radial wave function Rnl(r) 
   real(dp) function slater_Rn (r, n, Z_eff)
       


       implicit none
       integer, intent(in):: n ! principal quantum number
       real(dp), intent(in) :: r ! radial lenth , in Cartesian coordinate , unit is angstrom
       real(dp), intent(in) :: Z_eff ! effective nuclear charge number under slater rules
       

       !element_table ! 
       !nametol_list
       real(dp) ::  Rn_r ! answer of Rnl(r)
       real(dp) :: norm ! normalization factor
       integer :: n_fac
       
       call factorial(2*n , n_fac)
       
       norm = ((2d0*Z_eff)/(n*a_0))**n * sqrt(((2d0*Z_eff)/(n*a_0))/(n_fac))
       Rn_r = norm*(r)**(n-1)*exp(-((Z_eff*r)/(n*a_0)))

       slater_Rn = Rn_r
   end function slater_Rn

   !>When l=0,1,2,3 calculate the spherical bessel function
   real(dp) function spherical_bessel(x, l)


       implicit none
       integer, intent(in) :: l 
       real(dp) :: x

       ! when l is an integer, spherical bessel functions are elementary functions that can be expressed as 
       ! j_l(x) = (-1)^l x^l (\frac{1}{x}\frac{d}{dx})^l \frac{\sin x}{x}
       ! we only have to calculate the first four spherical bessel functions with l = 0,1,2,3
       
       !if(x == 0d0) then
       ! if(l == 0) then
       !     spherical_bessel = 1.0d0
       ! else
       !     spherical_bessel = 0.0d0
       ! end if
       ! return
       !end if

       x = x + 4d0*atan(1d0)*1E-10
       if (l == 0) then
           spherical_bessel = sin(x)/x
       else if(l == 1) then
           spherical_bessel = -cos(x)/x + sin(x)/(x**2)
       else if(l == 2) then
           spherical_bessel = -sin(x)/x - 3d0*cos(x)/(x**2) + 3d0*sin(x)/(x**3)
       else if(l == 3) then
           spherical_bessel = -cos(x)/x - 6d0*sin(x)/(x**2) - 15d0*cos(x)/(x**3) + 15d0*sin(x)/(x**4)
       else
           spherical_bessel = 0d0
       end if

   end function spherical_bessel

   !>When l=0,1,2,3 calculate the spherical harmonics
   complex(dp) function Ylm(theta, phi, l, m)


       implicit none
       real(dp), intent(in) :: theta, phi
       integer, intent(in) :: l, m


       if (l == 0) then
           if(abs(m) == 0) then
               Ylm = 0.5d0*sqrt(1.0/Pi)*cmplx(1.0d0, 0.0d0)
           else
               Ylm = cmplx(0.0d0, 0.0d0)
           end if
       else if(l == 1) then
           if(abs(m) == 0) then
               Ylm = 0.5*sqrt(3.0/Pi)*cos(theta)*cmplx(1.0d0, 0.0d0)
           else if(abs(m) == 1) then
               Ylm = -sign(1,m)*0.5*sqrt(3.0/(2d0*Pi))*exp(m*zi*phi)*sin(theta)
           else 
               Ylm = cmplx(0.0d0, 0.0d0)
           end if
       else if(l == 2) then
           if(abs(m) == 0) then
               Ylm = 0.25*sqrt(5/Pi)*(3*cos(theta)**2-1)*cmplx(1.0d0, 0.0d0)
           else if(abs(m) == 1) then
               Ylm = -sign(1,m)*0.5*sqrt(15.0/(2*Pi))*exp(m*zi*phi)*sin(theta)*cos(theta)
           else if(abs(m) == 2) then
               Ylm = 0.25*sqrt(15.0/(2*Pi))*exp(m*zi*phi)*sin(theta)**2
           else
               Ylm = cmplx(0.0d0, 0.0d0)
           end if
       else if(l == 3) then
           if(abs(m) == 0) then
               Ylm = 0.25*sqrt(7/Pi)*(5*cos(theta)**3-3*cos(theta))
           else if(abs(m) == 1) then
               Ylm = -sign(1,m)*(1.0/8)*sqrt(21/Pi)*exp(m*zi*phi)*sin(theta)*(5*cos(theta)**2-1)
           else if(abs(m) == 2) then
               Ylm = 0.25*sqrt(105/(2*Pi))*exp(m*zi*phi)*sin(theta)**2*cos(theta)
           else if(abs(m) == 3) then
               Ylm = -sign(1,m)*(1.0/8)*sqrt(35/Pi)*exp(m*zi*phi)*sin(theta)**3
           else
               Ylm = cmplx(0.0d0, 0.0d0)
           end if
       end if

   end function Ylm

   !> Generate the integrand function
   real(dp) function integrand(r, k_f, name, n, l)


       implicit none
       character(len=10) ,intent(in) :: name
       real(dp), intent(in) :: r
       real(dp), intent(in) :: k_f
       integer, intent(in) :: n
       integer, intent(in) :: l

       !external Z_eff_cal
       !real(dp), external :: slater_Rn, spherical_bessel

       real(dp) :: Z_eff ! effective nuclear charge number under slater rules
       real(dp) :: res


       call Z_eff_cal(name, n, l, Z_eff)
       !write(*,*) slater_Rn(r, n, Z_eff)
       res = (r**2)*slater_Rn(r, n, Z_eff)*spherical_bessel(k_f*r, l)
       integrand = res
   end function integrand


   !> Simpson integral
   subroutine integral_simpson(a, b, func, k_f, name, n, l, ans)


       implicit none
       real(dp), external :: func
       real(dp), intent(in) :: a
       real(dp), intent(in) :: b
       
       character(len=10) ,intent(in) :: name
       real(dp), intent(in) :: k_f
       integer, intent(in) :: n
       integer, intent(in) :: l

       real(dp) :: ans, aa
       real(dp) :: step
       integer :: i

       step = (b-a)/p_num
       ans = 0d0
       aa = a
       do i = 1, p_num
           aa = aa + step
           ans = (step/6d0)*(func(aa, k_f, name, n, l) + func((aa+step), k_f, name, n, l) + 4d0*func((2d0*aa+step)/2d0,&
            k_f, name, n, l))  + ans   
       end do
       
       
   end subroutine integral_simpson


   !> Simposon integral to infinity
   subroutine inf_integral(a, b, is_a_inf, is_b_inf, func, k_f, name, n, l, ans)


       implicit none
       real(dp), external :: func
       real(dp), intent(in) :: a
       real(dp), intent(in) :: b
       real(dp), intent(in) :: k_f
       logical, intent(in) :: is_a_inf, is_b_inf
       integer, intent(in) :: n
       integer, intent(in) :: l
       !external :: integral_simpson

       character(len=10) ,intent(in) :: name
       


       real(dp) :: ans
       real(dp) :: s, s_1, s_2, a_1, b_1, a_2, b_2

       
       s_1 = 0d0
       s_2 = 0d0
       a_1 = a
       b_1 = b
       a_2 = b + inte_step
       b_2 = a_2 + inte_step
       call integral_simpson(a_1, b_1, func, k_f, name, n, l, s)

       NO_1: do while(.true.)
           
           if ((is_a_inf == .false.).and.(is_b_inf == .false.)) then
               exit NO_1
           else
               if (is_a_inf == .true.) then
                   a_1 = a_1 - inte_step
                   a_2 = a_1 - inte_step
                   b_1 = b_1 - inte_step
                   b_2 = b_1 - inte_step
                   call integral_simpson(a_1, b_1, func, k_f, name, n, l, s_1)
                   call integral_simpson(a_2, b_2, func, k_f, name, n, l, s_2)
               end if

               if (is_b_inf == .true.) then
                   a_1 = b_1
                   b_1 = a_2
                   a_2 = b_2
                   b_2 = b_2 + inte_step
                   !write(*,*) s, s_1, s_2
                   !write(*,*) a_1, b_1
                   call integral_simpson(a_1, b_1, func, k_f, name, n, l, s_1)
                   call integral_simpson(a_2, b_2, func, k_f, name, n, l, s_2)
                   !write(*,*) s, s_1, s_2 
                   s_1 = s + s_1
                   s_2 = s_1 + s_2
                   s = s_1


               end if


               if (abs(abs(s_2 - s_1) - abs(s_1 - s)) < convergence_delta  ) exit NO_1
           end if



       end do NO_1

       ans = s_2
       !write(*,*) a_2, b_2

   end subroutine inf_integral


   !> Transform the k in cartesian to spherical coordinate
   subroutine cartesian_to_spherical(k_cart, k_f, theta, phi)


       implicit none
       real(dp), intent(in):: k_cart(3)
       real(dp) :: k_f, theta, phi ! value of phi is in [-π, π] 

       k_f = sqrt(k_cart(1)**2 + k_cart(2)**2 + k_cart(3)**2)
       if(k_f == 0) then
        theta = 0.0d0
        phi = 0.0d0
        return 
       end if
       theta = acos(k_cart(3)/k_f)
       phi = sign(acos(k_cart(2)/sqrt(k_cart(1)**2 + k_cart(2)**2)), k_cart(2))

       
   end subroutine cartesian_to_spherical


   subroutine get_matrix_element(ele_name, orb_name, k_cart, matrix_element_res)


       implicit none
       character(len=10), intent(in) :: ele_name
       character(len=10), intent(in) :: orb_name
       real(dp), intent(in):: k_cart(3) ! k in cartesian coordinate
       integer :: i

       !real(dp), external :: integrand
       !complex(dp), external :: Ylm
       !external :: Z_eff_cal, inf_integral, cartesian_to_spherical

       integer :: n, l, m ! orbital quantum numbers
       integer :: ele_ind ! element index
       integer :: ele_valence_configuration(lines_of_table, angular_number) ! valence electrons' configuration of element 
       
       
       real(dp) :: Z_eff
       real(dp) :: inte_res, inte_a = 0d0 
       real(dp) :: k_theta, k_phi, k_f ! k under spherical coordinate, k_f in the unit of angstrom^-1, k_theta and k_phi are in radian

       complex(dp) :: matrix_element_res
       real(dp) :: time_start, time_end

       
       
       !> get n,m,l of selected orbital
       call get_element_index(ele_name, ele_ind)
       call get_orbital_index(orb_name, l, m)
       call get_valence_config(ele_name, ele_valence_configuration)

       do i = 1, lines_of_table
           if(ele_valence_configuration(i, l+1) /= 0) then
               n = i
               exit
           end if
       end do
      ! write(*,*) n,l,m




       !> calculate the integral
       call cartesian_to_spherical(k_cart, k_f, k_theta, k_phi) ! get k under spherical coordinate
       write(*,*)"k_in_spherical", k_theta!k_f, , k_phi
       call Z_eff_cal(ele_name, n, l, Z_eff)
      ! write(*,*) Z_eff
       !call now(time_start)
       call integral_simpson(inte_a, inte_b, integrand, k_f, ele_name, n, l, inte_res)
       
       !> calculate the matrix element

       !write(*,*) inte_res
       
       matrix_element_res = inte_res*Ylm(k_theta, k_phi, l, m)*4d0*Pi*(-1)**l
        !write(*,*) Ylm(k_theta, k_phi, l, m), matrix_element_res
        !call now(time_end)
       !write(*,*) time_start, time_end
   end subroutine get_matrix_element

end module me_calculate