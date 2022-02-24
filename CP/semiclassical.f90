module parameters
  double precision,parameter:: pi=3.141592653589793d0
  double precision,parameter:: hbar=1.055d-34          ! J *s 
  double precision,parameter:: hbarev=6.582119514d-16  !eV *s
  double precision,parameter:: hev=4.135667662d-15  !eV *s
  double precision,parameter:: kb=1.38064852d-23       ! J* K-1
  double precision,parameter:: kbev=8.6173303d-5       !eV* K-1
  double precision,parameter:: ZERO=0.000000000000001d0  
  double precision,parameter:: Na=6.022140d23  	       !mol-1
  double precision,parameter:: c=299792458.0d0	       !m/s
  double precision,parameter:: ec=1.6021766208d-19      ! c
  double precision,parameter:: eps0=8.854187817d-12    !C V-1 m-1
  double precision,parameter:: me=9.10938356d-31       !kg
end module

program semiclassical
use parameters
implicit none
interface
  double precision function gp(e,e0,delta)
    double precision::e,e0,delta
  end function
  double precision function temp_corr(E,T,n)
    double precision::E,T,n
  end function
end interface

integer::i,j,k
double precision:: E0,EK,DE,E
double precision:: nm0,nmK,Dnm,nm
double precision,allocatable,dimension(:,:)::f,VEE
double precision::sigma,delta,factor,factoreps,errsigma,tmperr,fac2
double precision::T,n
integer::npoints,Nconf,Nroots,tmp,tempopt
integer::conf
character*(90)::INP,bodyinp,output,outputnm,outputeps,outputnmeps,msgoutput
character*(10)::confSTR
character*(90)::inpname

! f(:,:) - oscillator strength matrix
! f(i,:) <--- i-th geometrical configuration
! f(:,j) <--- j-th excited state
! VEE(:,:) - VEE strength matrix (eV),sorted increasingly
! VEE(i,:) <--- i-th geometrical configuration
! VEE(:,j) <--- j-th excited state

! E0 - beginning of spectrum (eV)
! EK - end of spectrum (eV)
! DE - interval of energy spectrum (eV)
! E - energy (eV)

! Nconf - number of configurations
! Nroots - number of roots

! delta - width of gaussian primitive (eV)
! tempopt - switch on (1) or off (0) the temperature corrections
! T - temperature [K]
! n - refraction index

!-------------------------------------
! Input section
!---
write (*,*) "Write name of the input file:"
read (*,*) inpname
open (unit=19,file=inpname,action='read')
read (19,*) bodyinp
read (19,*) Nconf,Nroots
read (19,*) E0,EK,DE
read (19,*) nm0,nmK,Dnm
read (19,*) delta
read (19,*) tempopt,T,n
close (unit=19)




allocate(VEE(Nconf,Nroots))
allocate(f(Nconf,Nroots))

!-------------------------------------
! Reading section
!---
!factor for cross sections sigma ()
!factor= pi*ec**2/(2.0d0*me*c*eps0)
factor= 10000*pi*ec**2/(2.0d0*me*c*eps0)
!factor for molar extinction coefficients epsilon ()
factoreps= factor*Na/1000/log(10.0)

msgoutput="msgs_"//bodyinp
write (*,*) "Message file: ", msgoutput
open (unit=40,file=msgoutput,action='write')
do conf=1,Nconf
  write (confSTR,'(i9)') conf
  INP="res"//trim(adjustl(confSTR))//"_"//trim(adjustl(bodyinp))//".dat"
  open (unit=20,file=INP,action='read')
  do i=1,Nroots
    read (20,*) k, VEE(conf,i), f(conf,i) 
  end do
  close (unit=20)
!-------------------------------------
! check the degeneracies -- turned off!!!
!---
!  call check_deg(VEE(conf,:),f(conf,:),Nroots,ETHRS,FTHRS,40,INP) 

end do



!-------------------------------------
! Calculating absorption cross section 
! sigma () and molar extinction coefficients epsilon ()
! for each energy
!---
output="spectr_"//bodyinp
outputnm="nm_spectr_"//bodyinp
outputeps="eps_spectr_"//bodyinp
outputnmeps="eps_nm_spectr_"//bodyinp

write (*,*) "Spectrum file[eV]: ", output
write (*,*) "Spectrum file[nm]: ", outputnm
write (*,*) "Spectrum file[eV]: ", outputeps
write (*,*) "Spectrum file[nm]: ", outputnmeps

open (unit=30,file=output,action='write')
open (unit=31,file=outputnm,action='write')

open (unit=50,file=outputeps,action='write')
open (unit=51,file=outputnmeps,action='write')

if (tempopt.eq.0) then
  write (30,'(a)') "# without temperature correction"
  write (31,'(a)') "# without temperature correction"
  write (50,'(a)') "# without temperature correction"
  write (51,'(a)') "# without temperature correction"
else if (tempopt.eq.1) then
  write (30,'(a)') "# with temperature correction"
  write (30,'(a,x,f8.3)') "# T=",T
  write (30,'(a,x,f10.5)') "# n=",n
  write (31,'(a)') "# with temperature correction"
  write (31,'(a,x,f8.3)') "# T=",T
  write (31,'(a,x,f10.5)') "# n=",n
  write (50,'(a)') "# with temperature correction"
  write (50,'(a,x,f8.3)') "# T=",T
  write (50,'(a,x,f10.5)') "# n=",n
  write (51,'(a)') "# with temperature correction"
  write (51,'(a,x,f8.3)') "# T=",T
  write (51,'(a,x,f10.5)') "# n=",n
end if
!write (30,'(a)') "# E[eV] sigma(E)[m2/molecule]"
!write (31,'(a)') "# E[nm] sigma(E)[m2/molecule]"
write (30,'(a)') "# E[eV] sigma(E)[cm2/molecule]"
write (31,'(a)') "# E[nm] sigma(E)[cm2/molecule]"
write (50,'(a)') "# E[eV] epsilon(E)[L/mol/cm]"
write (51,'(a)') "# E[nm] epsilon(E)[L/mol/cm]"
npoints=nint((EK-E0)/DE) +1

!-------------------------------------------------------------------------------------------------
! Spectrum in eV
!-------------------------------------------------------------------------------------------------
do i=1,npoints
  E=E0+dfloat(i-1)*DE
!-------------------------------------
! Calculation of sigma_av(E) (average)
!---
  sigma=0.0d0
  do j=1,Nconf
    do k=1,Nroots
      sigma=sigma+f(j,k)*gp(E,VEE(j,k),delta)
      !sigma=sigma+f(j,k)*gp(E,VEE(j,k),delta)*VEE(j,k)
    end do
  end do
  sigma=sigma/dfloat(Nconf)
!-------------------------------------
! Calculation of
!err_sigma(E)= dsqrt(sum_i^Nconf (sigma_i(E)-sigma_av(E))**2/(Np*(Np-1))
!---
  errsigma=0.0d0
  do j=1,Nconf
    tmperr=0.0d0
    do k=1,Nroots
      tmperr=tmperr+f(j,k)*gp(E,VEE(j,k),delta)
      !tmperr=tmperr+f(j,k)*gp(E,VEE(j,k),delta)*VEE(j,k)
    end do
    errsigma=errsigma+(tmperr-sigma)**2
  end do
  errsigma=dsqrt(errsigma/dfloat(Nconf*(Nconf-1)))

!-------------------------------------
! Temperature corrections
!---
  if (tempopt.eq.1) then
    sigma=sigma*temp_corr(E,T,n)
    errsigma=errsigma*temp_corr(E,T,n)
  end if
  !write (30,*) E, sigma*factor/E,errsigma*factor/E
  write (30,*) E, sigma*factor,errsigma*factor
  write (50,*) E, sigma*factoreps,errsigma*factoreps
end do  
close (unit=30)
close (unit=50)

!-------------------------------------------------------------------------------------------------
! Spectrum in nm
!-------------------------------------------------------------------------------------------------
npoints=nint((nmK-nm0)/Dnm)+1
fac2=hev*c*1.0d9
do i=1,npoints
  nm=nm0+dfloat(i-1)*Dnm
  E=fac2/nm
!-------------------------------------
! Calculation of sigma_av(E) (average)
!---
  sigma=0.0d0
  do j=1,Nconf
    do k=1,Nroots
      sigma=sigma+f(j,k)*gp(E,VEE(j,k),delta)
      !sigma=sigma+f(j,k)*gp(E,VEE(j,k),delta)*VEE(j,k)
    end do
  end do
  sigma=sigma/dfloat(Nconf)
!-------------------------------------
! Calculation of
!err_sigma(E)= dsqrt(sum_i^Nconf (sigma_i(E)-sigma_av(E))**2/(Np*(Np-1))
!---
  errsigma=0.0d0
  do j=1,Nconf
    tmperr=0.0d0
    do k=1,Nroots
      tmperr=tmperr+f(j,k)*gp(E,VEE(j,k),delta)
      !tmperr=tmperr+f(j,k)*gp(E,VEE(j,k),delta)*VEE(j,k)
    end do
    errsigma=errsigma+(tmperr-sigma)**2
  end do
  errsigma=dsqrt(errsigma/dfloat(Nconf*(Nconf-1)))

!-------------------------------------
! Temperature corrections
!---
  if (tempopt.eq.1) then
    sigma=sigma*temp_corr(E,T,n)
    errsigma=errsigma*temp_corr(E,T,n)
  end if
  write (31,*) nm, sigma*factor,errsigma*factor
  write (51,*) nm, sigma*factoreps,errsigma*factoreps
  !write (31,*) nm, sigma*factor/E,errsigma*factor/E
end do  
close (unit=31)
close (unit=51)
close (unit=40)
deallocate(f)
deallocate(VEE)
end program



!--------------------------gaussian primitive----------------------
double precision function gp(e,e0,delta)
  use parameters
  implicit none
  double precision::e,e0,delta
!----------------
! calculating value of gaussian primitive in point e
! e0 - position of maximum
! delta - broadening of gaussian
!---
  gp=dsqrt(2.0d0/pi) * (hbarev/delta)*dexp(-2.0d0*((e-e0)/delta)**2)
end function 
!-------------------------temperature correction to sigma----------
double precision function temp_corr(E,T,n)
  use parameters
  implicit none
  double precision::E,T,n
  temp_corr=(1.0d0-dexp(-E/(kbev*T)))/n
end function
!-----
subroutine check_deg(E,f,Nr,Ethr,fthr,index,filename)
  use parameters
  implicit none
  integer::Nr, index
  double precision,dimension(Nr)::E,f
  double precision::Ethr,fthr
  character*(50)::filename
  integer::cnt
  integer::i,j,k
!----------------
!  Check for degenerated states in E and f vectors
!  and remove them (setting E(i)=ZERO and f(i)=ZERO)
!  The threshold for comparision energies and f are 
!  Ethr and fthr, respectively
!---
  cnt=0
  do i=1,Nr-1
    if ((dabs(E(i+1)-E(i)).le.Ethr).and.(dabs(f(i+1)-f(i)).le.fthr)) then
      cnt=cnt+1
      E(i)=ZERO
      f(i)=ZERO
    else
      continue
    end if
  end do 
  write (index,'(a,x,a,x,a,x,i4)') "file: ",trim(adjustl(filename)), "number of degeneracies:", cnt
end subroutine
