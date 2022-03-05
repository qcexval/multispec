!! Modifications for 2nd March 2022
! to check posible errors and unused variables, run:
! gfortran -g -fcheck=all -Wall os2spec_2.f90

! create a module that will contain physical constants, subroutines and functions
module parameters
  !====== define physical constants
  double precision,parameter:: pi=3.141592653589793d0
  double precision,parameter:: hbar=1.055d-34          ! J *s 
  double precision,parameter:: hbarev=6.582119514d-16  !eV *s
  double precision,parameter:: hev=4.135667662d-15     !eV *s
  double precision,parameter:: kb=1.38064852d-23       ! J* K-1
  double precision,parameter:: kbev=8.6173303d-5       !eV* K-1
  double precision,parameter:: ZERO=0.000000000000001d0  
  double precision,parameter:: Na=6.022140d23  	       !mol-1
  double precision,parameter:: c=299792458.0d0	       !m/s
  double precision,parameter:: ec=1.6021766208d-19      ! c
  double precision,parameter:: eps0=8.854187817d-12    !C V-1 m-1
  double precision,parameter:: me=9.10938356d-31       !kg
  
  !====== define functions and subroutines
  contains
  !--------------------------Gaussian Line-Shape (gls)----------------------
    function gls(E,E0,delta)
      double precision, dimension(:)::E
      double precision::E0,delta
      double precision, dimension(:), allocatable::gls
      allocate(gls(size(E)))
      !----------------
      ! calculating value of normalized gaussian in energies E
      ! E0 - position of maximum
      ! delta - broadening of gaussian
      !---
      gls=dsqrt(2.0d0/pi) * (1/delta)*dexp(-2.0d0*((E-E0)/delta)**2)
    end function 
    
    !--------------------------Lorentzian Line Shape (lls)-------------------
    function lls(E,E0,delta)
      double precision, dimension(:)::E
      double precision::E0,delta
      double precision, dimension(:), allocatable::lls
      allocate(lls(size(E)))
      !----------------
      ! calculating value of normalized Lorenztian line-shape at energies E
      ! E0 - position of maximum
      ! delta - Lorentzian line-width
      !---
      lls = (1/pi)*(delta/2)/((E-E0)**2+(delta/2)**2)
    end function 
    
    !-------------------------temperature correction to sigma----------
    function temp_corr(E,T)
      double precision,parameter:: kbev=8.6173303d-5       !eV* K-1
      double precision, dimension(:)::E
      double precision::T
      double precision, dimension(:), allocatable::temp_corr
      allocate(temp_corr(size(E)))
      temp_corr=(1.0d0-dexp(-E/(kbev*T)))
    end function
    
    
    !-----
    subroutine check_deg(E,f,Nr,Ethr,fthr,index,filename)
      integer::Nr, index
      double precision,dimension(Nr)::E,f
      double precision::Ethr,fthr
      character*(50)::filename
      integer::cnt
      integer::i
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



    !!----------------absorption cross section calculation

    subroutine sigma_abs(E,f,VEE,Nconf,Nroots,delta,tempopt,T,n_r,sigma,errsigma)
      integer::j,k
      integer::Nconf,Nroots,tempopt
      double precision::delta,T,n_r,factor
      double precision::f(:,:),VEE(:,:),E(:)
      double precision, dimension(:), allocatable::tmperr
      double precision, dimension(:), allocatable, intent(out)::sigma,errsigma
      !------------
      ! subroutine to compute absorption cross sections from OS and VEE using
      ! the formalism in the documentation. Includes temperature and local-field 
      ! (refractive index) effects. Valid for ground state absorption (GSA) and 
      ! excited steate absorption (ESA)
  
      allocate(sigma(size(E)), errsigma(size(E)), tmperr(size(E)))
  
      !factor for cross sections sigma (cm2)
      factor = 10000*pi*ec**2*hbarev/(2.0d0*me*c*eps0*n_r)
  
      sigma=0.0d0
      do j=1,Nconf
        do k=1,Nroots
          sigma=sigma+VEE(j,k)*f(j,k)*gls(E,VEE(j,k),delta)/E
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
          tmperr=tmperr+VEE(j,k)*f(j,k)*gls(E,VEE(j,k),delta)/E
        end do
        errsigma=errsigma+(tmperr-sigma)**2
      end do
      errsigma=dsqrt(errsigma/dfloat(Nconf*(Nconf-1)))
      
      ! apply factors
      sigma = factor*sigma
      errsigma=factor*errsigma

    !-------------------------------------
    ! Temperature corrections
    !---
      if (tempopt.eq.1) then
        sigma=sigma*temp_corr(E,T)
        errsigma=errsigma*temp_corr(E,T)
      end if
   
    return   
    end


    !!---------stimulated emission cross section calculation

    subroutine sigma_stim(E,f,VEE,Nconf,Nroots,delta,n_r,plqy,Gamma,errGamma,sigma,errsigma,kappa,errkappa)
      integer::j,k
      integer::Nconf,Nroots
      double precision::delta,n_r,factor_g,factor_s,factor_n,plqy, tmperr_k
      double precision::f(:,:),VEE(:,:),E(:)
      double precision, dimension(:), allocatable::tmperr_g, tmperr_s
      double precision, dimension(:), allocatable, intent(out)::Gamma,errGamma,sigma,errsigma
      double precision, intent(out)::kappa,errkappa
      !------------
      ! subroutine to compute differential decay rate, total decay rate, and 
      ! stimulated emission cross sections from OS and VEE using
      ! the formalism in the documentation. Includes temperature and local-field 
      ! (refractive index) effects. 
      
      allocate(Gamma(size(E)),errGamma(size(E)),sigma(size(E)), errsigma(size(E)), tmperr_g(size(E)), tmperr_s(size(E)))
  
      !factor for differential decay rate (factor_g)
      factor_n = n_r*(3.0e0*n_r**2/(2.0d0*n_r**2+1))**2 ! Refractive index correction
      factor_g = ec**2*factor_n/(2.0d0*pi*hbarev*me*c**3*eps0)
      
      ! factor for cross (section factor_s); add quantum yield correction
      factor_s = 10000*pi**2*c**2*hbarev**2/n_r**2
      factor_s = plqy*factor_s*factor_g
  
      Gamma=0.0d0
      sigma=0.0d0
      do j=1,Nconf
        do k=1,Nroots
          Gamma=Gamma+f(j,k)*VEE(j,k)**2*lls(E,VEE(j,k),delta)
          sigma=sigma+f(j,k)*lls(E,VEE(j,k),delta)
        end do
      end do
      Gamma=Gamma/dfloat(Nconf)
      sigma=sigma/dfloat(Nconf)
      
      !-------------------------------------
      ! Calculation of errors
      !err_Gamma(E)= dsqrt(sum_i^Nconf (Gamma_i(E)-Gamma_av(E))**2/(Np*(Np-1))
      !---
      errGamma=0.0d0
      errsigma=0.0d0
      do j=1,Nconf
        tmperr_g=0.0d0
        tmperr_s=0.0d0
        do k=1,Nroots
          tmperr_g=tmperr_g+f(j,k)*VEE(j,k)**2*lls(E,VEE(j,k),delta)
          tmperr_s=tmperr_s+f(j,k)*lls(E,VEE(j,k),delta)
        end do
        errGamma=errGamma+(tmperr_g-Gamma)**2
        errsigma=errsigma+(tmperr_s-sigma)**2
      end do
      errGamma = dsqrt(errGamma/dfloat(Nconf*(Nconf-1)))
      errsigma = dsqrt(errsigma/dfloat(Nconf*(Nconf-1)))
      
      ! apply  factors
      Gamma = factor_g*Gamma
      errGamma= factor_g*errGamma
      sigma = factor_s*sigma
      errsigma = factor_s*errsigma
      
      
      ! radiative decay rate kappa=1/hbar*int(Gamma)
      ! Hint: int(lls)=1
      kappa = 0.0d0
      do j=1,Nconf
        do k=1,Nroots
          kappa=kappa+f(j,k)*VEE(j,k)**2
        end do
      end do
      kappa=kappa/dfloat(Nconf)
      
      ! calculation of error
      errkappa=0.0d0
      do j=1,Nconf
        tmperr_k=0.0d0
        do k=1,Nroots
          tmperr_k=tmperr_k+f(j,k)*VEE(j,k)**2
        end do
        errkappa=errkappa+(tmperr_k-kappa)**2
      end do
      errkappa = dsqrt(errkappa/dfloat(Nconf*(Nconf-1)))
      
      ! apply factors
      kappa = factor_g/hbarev*kappa
      errkappa = factor_g/hbarev*errkappa
      
  return   
  end
    
end module parameters


!===========================================================================
!========= START PROGRAM 
!========================================================================


program os2spec
use parameters
implicit none
integer::i,j,k
double precision:: E0,EK,DE
double precision:: wl0,wlK,Dwl
double precision, dimension(:), allocatable::Eev,wl
double precision,allocatable,dimension(:,:)::f_gsa,VEE_gsa,f_em,VEE_em,f_esa,VEE_esa
double precision,allocatable,dimension(:)::sigma_gsa,errsigma_gsa,sigma_em,errsigma_em,sigma_esa,errsigma_esa,sigma_ta,errsigma_ta
double precision,allocatable,dimension(:)::Gamma,errGamma
double precision::delta_gsa,delta_em,delta_esa,factoreps,fac2
double precision::T,n_gsa,n_em,n_esa,plqy,kappa,errkappa
integer::npoints,Nconf_gsa,Nroots_gsa,Nconf_em,Nroots_em,Nconf_esa,Nroots_esa,tempopt
integer::conf
character*(90)::INP,outname,bodyinp_gsa,bodyinp_em,bodyinp_esa,output,&
                outputnm,outputeps,outputnmeps,outputgamma,outputnmgamma,msgoutput
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

! wl0 - beginning of spectrum (nm)
! wlK - end of spectrum (nm)
! Dwl - interval of energy spectrum (nm)
! wl - wavelength (nm)

! Nconf - number of configurations
! Nroots - number of roots

! delta - width of Gaussian or Lorentzian line-shapes (eV)
! tempopt - switch on (1) or off (0) the temperature corrections
! T - temperature [K]
! n_gsa - refractive index at ground state absorption band
! n_em - refractive index at emission band
! g_esa - refractive index at excited state absorption band
! plqy - photoluminescence Quantum Yield (plqy)

! sigma_gsa - ground state absorption cross section (cm2)
! sigma_esa - excited state absorption cross section (cm2)
! sigma_ta - transient absorption cross section (cm2)
! sigma_em - stimulated emission cross section (cm2)
! Gamma - Spontaneous emission spectrum (adimensional)
! kappa - radiative decay rate (s^-1)

!-------------------------------------
! Input section
!---
write (*,*) "Write name of the input file:"
read (*,*) inpname
open (unit=19,file=inpname,action='read')
read (19,*) outname
read (19,*) bodyinp_gsa
read (19,*) bodyinp_em
read (19,*) bodyinp_esa
read (19,*) Nconf_gsa,Nroots_gsa
read (19,*) Nconf_em,Nroots_em
read (19,*) Nconf_esa,Nroots_esa
read (19,*) E0,EK,DE
read (19,*) wl0,wlK,Dwl
read (19,*) delta_gsa,delta_em,delta_esa
read (19,*) tempopt,T
read (19,*) n_gsa,n_em,n_esa
read (19,*) plqy
close (unit=19)

! allocate memory
! for gsa
if (Nconf_gsa.eq.0) then
  allocate(VEE_gsa(2,1)) ! 2 confs to avoid Nans in errors
  allocate(f_gsa(2,1)) ! 2 confs to avoid Nans in errors
else
  allocate(VEE_gsa(Nconf_gsa,Nroots_gsa))
  allocate(f_gsa(Nconf_gsa,Nroots_gsa))  
end if


! for em
if (Nconf_em.eq.0) then
  allocate(VEE_em(2,1)) ! 2 confs to avoid Nans in errors
  allocate(f_em(2,1)) ! 2 confs to avoid Nans in errors
else
  allocate(VEE_em(Nconf_em,Nroots_em))
  allocate(f_em(Nconf_em,Nroots_em))  
end if

! for esa
if (Nconf_esa.eq.0) then
  allocate(VEE_esa(2,1)) ! 2 confs to avoid Nans in errors
  allocate(f_esa(2,1)) ! 2 confs to avoid Nans in errors
else
  allocate(VEE_esa(Nconf_esa,Nroots_esa))
  allocate(f_esa(Nconf_esa,Nroots_esa))
end if



!-------------------------------------
! Reading section
!---

msgoutput="msgs_"//outname
write (*,*) "Message file: ", msgoutput
open (unit=40,file=msgoutput,action='write')

! read gsa files
if (Nconf_gsa.ne.0) then
  do conf=1,Nconf_gsa
    write (confSTR,'(i9)') conf
    INP="res"//trim(adjustl(confSTR))//"_"//trim(adjustl(bodyinp_gsa))//".dat"
    open (unit=20,file=INP,action='read')
    do i=1,Nroots_gsa
      read (20,*) k, VEE_gsa(conf,i), f_gsa(conf,i) 
    end do
    close (unit=20)
!-------------------------------------
! check the degeneracies -- turned off!!!
!---
!  call check_deg(VEE_gsa(conf,:),f_gsa(conf,:),Nroots_gsa,ETHRS,FTHRS,40,INP) 

  end do
else
  VEE_gsa=0.0
  f_gsa=0.0
  Nconf_gsa = 2 ! 2 confs to avoid Nans in errors
end if

! read em files
if (Nconf_em.ne.0) then
  do conf=1,Nconf_em
    write (confSTR,'(i9)') conf
    INP="res"//trim(adjustl(confSTR))//"_"//trim(adjustl(bodyinp_em))//".dat"
    open (unit=20,file=INP,action='read')
    do i=1,Nroots_em
      read (20,*) k, VEE_em(conf,i), f_em(conf,i) 
    end do
    close (unit=20)
!-------------------------------------
! check the degeneracies -- turned off!!!
!---
!  call check_deg(VEE_em(conf,:),f_em(conf,:),Nroots_em,ETHRS,FTHRS,40,INP) 

  end do
else
  VEE_em=0.0
  f_em=0.0
  Nconf_em = 2 ! 2 confs to avoid Nans in errors
end if

! read esa files
if (Nconf_esa.ne.0) then
  do conf=1,Nconf_esa
    write (confSTR,'(i9)') conf
    INP="res"//trim(adjustl(confSTR))//"_"//trim(adjustl(bodyinp_esa))//".dat"
    open (unit=20,file=INP,action='read')
    do i=1,Nroots_esa
      read (20,*) k, VEE_esa(conf,i), f_esa(conf,i) 
    end do
    close (unit=20)
!-------------------------------------
! check the degeneracies -- turned off!!!
!---
!  call check_deg(VEE_esa(conf,:),f_esa(conf,:),Nroots_esa,ETHRS,FTHRS,40,INP) 

  end do
else
  VEE_esa=0.0
  f_esa=0.0 
  Nconf_esa = 2 ! 2 confs to avoid Nans in errors
end if


!-------------------------------------
! Writting section
!---

output="spectr_"//trim(adjustl(outname))//".txt"
outputnm="spectr_nm_"//trim(adjustl(outname))//".txt"
outputeps="eps_spectr_"//trim(adjustl(outname))//".txt"
outputnmeps="eps_nm_spectr_"//trim(adjustl(outname))//".txt"
outputgamma="gamma_spectr_"//trim(adjustl(outname))//".txt"
outputnmgamma="gamma_nm_spectr_"//trim(adjustl(outname))//".txt"

write (*,*) "Cross section spectrum file[eV]: ", output
write (*,*) "Cross section spectrum file[nm]: ", outputnm
write (*,*) "Molar extinction spectrum file[eV]: ", outputeps
write (*,*) "Molar extinction spectrum file[nm]: ", outputnmeps
write (*,*) "Differential decay rate spectrum file[eV]: ", outputgamma
write (*,*) "Differential decay rate spectrum file[nm]: ", outputnmgamma

open (unit=30,file=output,action='write')
open (unit=31,file=outputnm,action='write')

open (unit=50,file=outputeps,action='write')
open (unit=51,file=outputnmeps,action='write')

open (unit=70,file=outputgamma,action='write')
open (unit=71,file=outputnmgamma,action='write')


! Add header

if (tempopt.eq.0) then
  write (30,'(a)') "# without temperature correction"
  write (31,'(a)') "# without temperature correction"
  write (50,'(a)') "# without temperature correction"
  write (51,'(a)') "# without temperature correction"
else if (tempopt.eq.1) then
  write (30,'(a)') "# with temperature correction"
  write (30,'(a,x,f8.3)') "# T=",T
  write (31,'(a)') "# with temperature correction"
  write (31,'(a,x,f8.3)') "# T=",T
  write (50,'(a)') "# with temperature correction"
  write (50,'(a,x,f8.3)') "# T=",T
  write (51,'(a)') "# with temperature correction"
  write (51,'(a,x,f8.3)') "# T=",T
end if

write (30,'(a,x,f10.5)') "# Input quantum yield (plqy) = ", plqy
write (31,'(a,x,f10.5)') "# Input quantum yield (plqy) = ", plqy
write (50,'(a,x,f10.5)') "# Input quantum yield (plqy) = ", plqy
write (51,'(a,x,f10.5)') "# Input quantum yield (plqy) = ", plqy

write (30,'(a)') "# Column 1: E[eV]"
write (30,'(a)') "# Column 2: sigma_gsa(E)[cm2/molecule] (mean)"
write (30,'(a)') "# Column 3: sigma_gsa(E)[cm2/molecule] (std)"
write (30,'(a)') "# Column 4: sigma_em(E)[cm2/molecule] (mean)"
write (30,'(a)') "# Column 5: sigma_em(E)[cm2/molecule] (std)"
write (30,'(a)') "# Column 6: sigma_esa(E)[cm2/molecule] (mean)"
write (30,'(a)') "# Column 7: sigma_esa(E)[cm2/molecule] (std)"
write (30,'(a)') "# Column 8: sigma_ta(E)[cm2/molecule] (mean)"
write (30,'(a)') "# Column 9: sigma_ta(E)[cm2/molecule] (std)"

write (31,'(a)') "# Column 1: wl[nm]"
write (31,'(a)') "# Column 2: sigma_gsa(wl)[cm2/molecule] (mean)"
write (31,'(a)') "# Column 3: sigma_gsa(wl)[cm2/molecule] (std)"
write (31,'(a)') "# Column 4: sigma_em(wl)[cm2/molecule] (mean)"
write (31,'(a)') "# Column 5: sigma_em(wl)[cm2/molecule] (std)"
write (31,'(a)') "# Column 6: sigma_esa(wl)[cm2/molecule] (mean)"
write (31,'(a)') "# Column 7: sigma_esa(wl)[cm2/molecule] (std)"
write (31,'(a)') "# Column 8: sigma_ta(wl)[cm2/molecule] (mean)"
write (31,'(a)') "# Column 9: sigma_ta(wl)[cm2/molecule] (std)"

write (50,'(a)') "# Column 1: E[eV]"
write (50,'(a)') "# Column 2: epsilon_gsa(E)[cm2/molecule] (mean)"
write (50,'(a)') "# Column 3: epsilon_gsa(E)[cm2/molecule] (std)"
write (50,'(a)') "# Column 4: epsilon_em(E)[cm2/molecule] (mean)"
write (50,'(a)') "# Column 5: epsilon_em(E)[cm2/molecule] (std)"
write (50,'(a)') "# Column 6: epsilon_esa(E)[cm2/molecule] (mean)"
write (50,'(a)') "# Column 7: epsilon_esa(E)[cm2/molecule] (std)"
write (50,'(a)') "# Column 8: epsilon_ta(E)[cm2/molecule] (mean)"
write (50,'(a)') "# Column 9: epsilon_ta(E)[cm2/molecule] (std)"

write (51,'(a)') "# Column 1: wl[nm]"
write (51,'(a)') "# Column 2: epsilon_gsa(wl)[cm2/molecule] (mean)"
write (51,'(a)') "# Column 3: epsilon_gsa(wl)[cm2/molecule] (std)"
write (51,'(a)') "# Column 4: epsilon_em(wl)[cm2/molecule] (mean)"
write (51,'(a)') "# Column 5: epsilon_em(wl)[cm2/molecule] (std)"
write (51,'(a)') "# Column 6: epsilon_esa(wl)[cm2/molecule] (mean)"
write (51,'(a)') "# Column 7: epsilon_esa(wl)[cm2/molecule] (std)"
write (51,'(a)') "# Column 8: epsilon_ta(wl)[cm2/molecule] (mean)"
write (51,'(a)') "# Column 9: epsilon_ta(wl)[cm2/molecule] (std)"

write (70,'(a)') "# Column 1: E[eV]"
write (70,'(a)') "# Column 2: Gamma(E)[none] (mean)"
write (70,'(a)') "# Column 3: Gamma(E)[none] (std)"
write (71,'(a)') "# Column 1: wl[nm]"
write (71,'(a)') "# Column 2: Gamma(wl)[none] (mean)"
write (71,'(a)') "# Column 3: Gamma(wl)[none] (std)"



!-------------------------------------
! Spectra calculation and writing into file section
!---

!-------------------------------------------------------------------------------------------------
! Spectra in eV
!-------------------------------------------------------------------------------------------------
npoints=nint((EK-E0)/DE) + 1

allocate(Eev(npoints),sigma_ta(npoints),errsigma_ta(npoints))

! assign energy values to array
do i=1,npoints
  Eev(i) = E0+dfloat(i-1)*DE
end do

!-------------------------------------
! Calculation of cross sections (mean and std)
!---
! GSA spectrum
call sigma_abs(Eev,f_gsa,VEE_gsa,Nconf_gsa,Nroots_gsa,delta_gsa,tempopt,T,n_gsa,sigma_gsa,errsigma_gsa)

! ST spectrum
call sigma_stim(Eev,f_em,VEE_em,Nconf_em,Nroots_em,delta_em,n_em,plqy,Gamma,errGamma,sigma_em,errsigma_em,kappa,errkappa)

write (70,'(a,x,ES15.5E2)') "# Decay Rate [s^-1] (mean) = ", kappa
write (70,'(a,x,ES15.5E2)') "# Decay Rate [s^-1] (std)  = ", errkappa

! ESA spectrum
call sigma_abs(Eev,f_esa,VEE_esa,Nconf_esa,Nroots_esa,delta_esa,tempopt,T,n_esa,sigma_esa,errsigma_esa)

! TA spectrum
sigma_ta = sigma_esa-sigma_em-sigma_gsa
errsigma_ta = dsqrt(errsigma_gsa**2+errsigma_em**2+errsigma_esa**2)

! factor for cross section sigma (cm2)
! to molar extinction coefficient epsilon (M-1 cm-1)
factoreps= Na/1000/log(10.0)

do i=1,npoints
  write (30,*) Eev(i),&
               sigma_gsa(i),&
               errsigma_gsa(i),&
               sigma_em(i),&
               errsigma_em(i),&
               sigma_esa(i),&
               errsigma_esa(i),&
               sigma_ta(i),&
               errsigma_ta(i)
  write (50,*) Eev(i),&
               sigma_gsa(i)*factoreps,&
               errsigma_gsa(i)*factoreps,&
               sigma_em(i)*factoreps,&
               errsigma_em(i)*factoreps,&
               sigma_esa(i)*factoreps,&
               errsigma_esa(i)*factoreps,&
               sigma_ta(i)*factoreps,&
               errsigma_ta(i)*factoreps
  write (70,*) Eev(i),&
               Gamma(i),&
               errGamma(i)
end do  
close (unit=30)
close (unit=50)
close (unit=70)

deallocate(Eev,sigma_ta,errsigma_ta)

!-------------------------------------------------------------------------------------------------
! Spectra in nm
!-------------------------------------------------------------------------------------------------
npoints=nint((wlK-wl0)/Dwl)+1

allocate(wl(npoints),Eev(npoints),sigma_ta(npoints),errsigma_ta(npoints))

do i=1,npoints
  wl(i)=wl0+dfloat(i-1)*Dwl
end do
! reassign energy values
fac2=hev*c*1.0d9
Eev=fac2/wl

!-------------------------------------
! Calculation of cross section (mean and std)
!---
! GSA spectrum
call sigma_abs(Eev,f_gsa,VEE_gsa,Nconf_gsa,Nroots_gsa,delta_gsa,tempopt,T,n_gsa,sigma_gsa,errsigma_gsa)

! ST spectrum
call sigma_stim(Eev,f_em,VEE_em,Nconf_em,Nroots_em,delta_em,n_em,plqy,Gamma,errGamma,sigma_em,errsigma_em,kappa,errkappa)

write (71,'(a,x,ES15.5E2)') "# Decay Rate [s^-1] (mean) = ", kappa
write (71,'(a,x,ES15.5E2)') "# Decay Rate [s^-1] (std)  = ", errkappa

! ESA spectrum
call sigma_abs(Eev,f_esa,VEE_esa,Nconf_esa,Nroots_esa,delta_esa,tempopt,T,n_esa,sigma_esa,errsigma_esa)

! TA spectrum
sigma_ta = sigma_esa-sigma_em-sigma_gsa
errsigma_ta = dsqrt(errsigma_gsa**2+errsigma_em**2+errsigma_esa**2)

do i=1,npoints
  write (31,*) wl(i),&
               sigma_gsa(i),&
               errsigma_gsa(i),&
               sigma_em(i),&
               errsigma_em(i),&
               sigma_esa(i),&
               errsigma_esa(i),&
               sigma_ta(i),&
               errsigma_ta(i)
  write (51,*) wl(i),&
               sigma_gsa(i)*factoreps,&
               errsigma_gsa(i)*factoreps,&
               sigma_em(i)*factoreps,&
               errsigma_em(i)*factoreps,&
               sigma_esa(i)*factoreps,&
               errsigma_esa(i)*factoreps,&
               sigma_ta(i)*factoreps,&
               errsigma_ta(i)*factoreps
  write (71,*) wl(i),&
               Gamma(i),&
               errGamma(i)
end do  
close (unit=31)
close (unit=51)
close (unit=71)


close (unit=40)

end program


