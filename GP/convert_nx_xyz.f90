program convert


Character(2),allocatable,dimension(:)::ATYPE
double precision,allocatable,dimension(:,:)::XYZ,REFXYZ
double precision::tmpat,rmsd
double precision,parameter::bohrtoa=0.52917721092d0
integer::Nat,Nconf
character(10)::NatSTR,confSTR
character(30)::input
character(50)::bodyname,FORMAT1,outtot,outsin
integer::i,j,k

!------------------------
! Input section
!---
open(1, file = 'variables4f90.inp', status = 'old')
!write (*,*) "Input name of NX output with distribution:"
read (1,*) input
!write (*,*) "Number of atoms?"
read (1,*) Nat
!write (*,*) "Number of geometries?"
read (1,*) Nconf
!write (*,*) "Name of the new .xyz files?"
read (1,*) bodyname
close(1)



FORMAT1='(a,x,3(ES15.7,x))'
allocate (XYZ(Nat,3))
allocate (REFXYZ(Nat,3))
allocate (ATYPE(Nat))
!------------------------
! Creating temporary file 'tmp' with grepped NX geoms
!---

write (NatSTR,'(i9)') Nat
call system('grep -A '//trim(adjustl(NatSTR))//' "Geometry in COLUMBUS and NX input format:" '//&
&trim(adjustl(input))//' > tmp' )
call system('echo "--" >> tmp')

rmsd=0.0d0
outtot="snaps_"//trim(adjustl(bodyname))//".xyz"
open (unit=20,file='tmp',action='read')
open (unit=30,file=outtot,action='write')
do i=1,Nconf
  write (confSTR,'(i9)') i
  outsin="g"//trim(adjustl(confSTR))//"_"//trim(adjustl(bodyname))//".xyz"
  open (unit=40,file=outsin,action='write')
!---------------------
! Reading from 'tmp' file
!---
  read (20,*) 
  do j=1,Nat
    read (20,*) ATYPE(j), tmpat,(XYZ(j,k),k=1,3) 
  end do
  read (20,*)
!---------------------
! Calculating RMSD
!---
  if ( i.eq.1) then
    do j=1,Nat
      REFXYZ(j,1)=XYZ(j,1)
      REFXYZ(j,2)=XYZ(j,2)
      REFXYZ(j,3)=XYZ(j,3)
    end do
  else
    do j=1,Nat
      rmsd=rmsd+(XYZ(j,1)-REFXYZ(j,1))**2+(XYZ(j,2)-REFXYZ(j,2))**2+(XYZ(j,3)-REFXYZ(j,3))**2
    end do
  end if 
!---------------------
! Writing to the file with all of the geometries
! Can be used to visualise in molden and quickly notice,
! what kind of geometries one obtained from distribution
!---
  write (30,*) Nat
  write (30,*) 
  do j=1,Nat
    write (30,FORMAT1) ATYPE(j), (bohrtoa*XYZ(j,k),k=1,3) 
  end do

!---------------------
! Writing to the single .xyz files with sampled geometries
!---
  write (40,*) Nat
  write (40,*) 
  do j=1,Nat
    write (40,FORMAT1) ATYPE(j), (bohrtoa*XYZ(j,k),k=1,3) 
  end do
  close (unit=40)
end do
rmsd=dsqrt(rmsd/Nconf)*bohrtoa
write (*,'(a,x,f12.5)') "RMSD (A)= ",rmsd
close (unit=20)
close (unit=30)
deallocate (XYZ)
deallocate (ATYPE)
end program
