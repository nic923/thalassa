module COWELL
! Description:
!    Contains procedures necessary to integrate the Cowell formulation.
!
! Author:
!    Davide Amato
!    Space Dynamics Group - Technical University of Madrid
!    d.amato@upm.es
!
! ==============================================================================

use KINDS, only: dk
implicit none


contains


subroutine COWELL_RHS(neq,t,y,ydot)
! Description:
!    Computes the value of the right-hand side of the 1st-order equations of
!    motion of the Cowell formulation.
!
! ==============================================================================

! MODULES
use AUXILIARIES,   only: DU,TU
use SETTINGS,      only: insgrav,isun,imoon,idrag,iSRP
use PERTURBATIONS, only: PACC_EJ2K

! VARIABLES
implicit none

! Arguments
integer,intent(in)     ::  neq             ! Number of equations.
real(dk),intent(in)    ::  t               ! Time, ND.
real(dk),intent(in)    ::  y(1:neq)        ! Cartesian state vector, ND.
real(dk),intent(out)   ::  ydot(1:neq)     ! RHS of EoM's, ND.

! Local variables
real(dk)          ::  rMag                     ! Magnitude of position vector. [-]
real(dk)          ::  p_EJ2K(1:3)              ! Perturbation acceleration in the inertial frame. [-]

! ==============================================================================

rMag = sqrt(dot_product(y(1:3),y(1:3)))

! ==============================================================================
! 01. COMPUTE PERTURBATIONS IN THE EMEJ2000 FRAME
! ==============================================================================

p_EJ2K = 0._dk
p_EJ2K = PACC_EJ2K(insgrav,isun,imoon,idrag,iSRP,y(1:3),y(4:6),rMag,t)

! ==============================================================================
! 02. EVALUATE RIGHT-HAND SIDE
! ==============================================================================

ydot(1:3) = y(4:6)
ydot(4:6) = -y(1:3)/rMag**3 + p_EJ2K

end subroutine COWELL_RHS


subroutine COWELL_EVT(neq,t,y,ng,roots)
! Description:
!    Finds roots to stop the integration for the Cowell formulation.
!    Quad precision.
!
! ==============================================================================

! MODULES
use AUXILIARIES, only: MJD0,MJDnext,MJDf,TU,DU
use PHYS_CONST,  only: secsPerDay,reentry_radius_nd

! VARIABLES
implicit none
! Arguments IN
integer,intent(in)       ::  neq
integer,intent(in)       ::  ng
real(dk),intent(in)      ::  t
real(dk),intent(in)      ::  y(1:neq)
! Arguments OUT
real(dk),intent(out)     ::  roots(1:ng)
! Locals
real(dk)  ::  rmag

! ==============================================================================

roots = 1._dk
! ==============================================================================
! 01. Next timestep (DISABLED)
! ==============================================================================

!roots(1) = t - MJDnext*secsPerDay*TU
roots(1) = 1._dk

! ==============================================================================
! 02. Stop integration
! ==============================================================================

roots(2) = t - (MJDf-MJD0)*secsPerDay*TU
!roots(2) = 1._dk

! ==============================================================================
! 03. Re-entry
! ==============================================================================

rmag = sqrt(dot_product(y(1:3),y(1:3)))
roots(3) = rmag - reentry_radius_nd

end subroutine COWELL_EVT


end module COWELL