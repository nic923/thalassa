module IO
! Description:
!    Input/output subroutines for Thalassa.
!
! Author:
!    Davide Amato
!    Space Dynamics Group - Technical University of Madrid
!    d.amato@upm.es
!
! ==============================================================================

! MODULES
use KINDS, only: dk
use SETTINGS, only: outpath

! VARIABLES
implicit none
integer,parameter    ::  id_ic = 10, id_in = 11, id_cart = 12, id_orb = 13
integer,parameter    ::  id_stat = 14
character(len=512)   ::  object_path

contains


subroutine READ_IC(MJD,COE)

! MODULES
use PHYS_CONST, only: SCMass,ADrag,ASRP,CD,CR,A2M_Drag,A2M_SRP

! VARIABLES
implicit none
! Arguments
real(dk),intent(out)  ::  MJD,COE(1:6)

! Locals
integer,parameter     ::  hlines = 3
character(len=64)     ::  dummy
integer               ::  i


! ==============================================================================

open(unit=id_ic,file=adjustl(trim(object_path)),status='old',action='read')

! Skip header lines
read(id_ic,'(a)') (dummy, i=1,hlines)

! Orbital elements: a [km], e, i [deg], Om [deg], w [deg], M [deg]
read(id_ic,'(e22.15,a)') MJD, dummy
do i=1,6
    read(id_ic,'(e22.15,a)') COE(i), dummy
end do

! CD and A/m
read(id_ic,'(/,e22.15,a)') SCMass
read(id_ic,'(e22.15,a)') ADrag
read(id_ic,'(e22.15,a)') ASRP
read(id_ic,'(e22.15,a)') CD
read(id_ic,'(e22.15,a)') CR

close(id_ic)

! Area-to-mass ratios
A2M_Drag = ADrag/SCMass
A2M_SRP  = ASRP/SCmass

end subroutine READ_IC


subroutine CREATE_OUT(fid)
! Description:
!    Creates an output file and writes the header.
!
! ==============================================================================

! VARIABLES
implicit none
integer,intent(in)       ::  fid
character(len=4096)      ::  filepath
integer,parameter        ::  hlines = 3
character(len=512)       ::  header(hlines)
logical                  ::  stat_exists

! ==============================================================================

select case (fid)
    case(12) ! Cartesian trajectory file, id_cart = 12 (see module preamble)
        filepath = adjustl(trim(outpath)//'cart.dat')
        header(1) = '# THALASSA - CARTESIAN COORDINATES'
        write(header(2),'(''#'',160(''=''))')
        write(header(3),'(''#'',a21,1x,6(a22,1x))') &
        & 'MJD', 'X [km]', 'Y [km]', 'Z [km]', 'VX [km]', 'VY [km]', 'VZ [km]'
        open(unit=fid,file=trim(filepath),action='write',status='replace')
        write(fid,'(a200)') header

    case(13) ! Orbital elements file, id_orb = 13 (see module preamble)
        filepath = adjustl(trim(outpath)//'orbels.dat')
        header(1) = '# THALASSA - ORBITAL ELEMENTS'
        write(header(2),'(''#'',160(''=''))')
        write(header(3),'(''#'',a21,1x,6(a22,1x))') &
        & 'MJD', 'SMA [km]', 'ECC [-]', 'INC [deg]', 'RAAN [deg]', 'AOP [deg]', 'MA [deg]'
        open(unit=fid,file=trim(filepath),action='write',status='replace')
        write(fid,'(a200)') header

    case(14) ! Integration statistics file, id_stat = 14 (see module preamble)
        filepath = adjustl(trim(outpath)//'stats.dat')
        header(1) = '# THALASSA - STATISTICS'
        write(header(2),'(''#'',227(''=''))')
        write(header(3),'(''#'',a9,a11,9(a23))')&
        & 'CALLS', 'STEPS', 'TOL', 'CPUT [s]', 'MJD', 'SMA [km]', 'ECC [-]',&
        & 'INC [deg]', 'RAAN [deg]', 'AOP [deg]', 'MA [deg]'
        inquire(file=trim(filepath),exist=stat_exists)
        if (stat_exists) then
          open(unit=fid,file=trim(filepath),position='append',action='write',status='old')
          
        else
          open(unit=fid,file=trim(filepath),action='write',status='new')
          write(fid,'(a228)') header
          
        end if

end select




end subroutine CREATE_OUT


subroutine DUMP_TRAJ(fid,npts,yx)
! Description:
!    Dumps trajectory to the ASCII file specified by fid, and closes the file.
!
! ==============================================================================

! variables
implicit none
integer,intent(in)   ::  fid,npts
real(dk),intent(in)  ::  yx(1:npts,1:7)
integer  ::  iwr

! ==============================================================================

write(fid,'(7(es22.15,'',''))') (yx(iwr,1:7), iwr=1,npts)
close(fid)

end subroutine DUMP_TRAJ


end module IO