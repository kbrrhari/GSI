!=================================================================================
!  grads_lev
!
!    Read in data from the .tmp file, arrange by level and write into 
!    the GrADS data files (one for scatter plots, and one for horizontal plots)
!    depending on the iscater and igrads parameters.
!=================================================================================


subroutine grads_lev(fileo,ifileo,nobs,nreal,nlev,plev,iscater,igrads,&
                        levcard,hint,isubtype,subtype,list)

   use generic_list
   use data

   implicit none

   type(list_node_t), pointer   :: list
   type(list_node_t), pointer   :: next => null()
   type(data_ptr)               :: ptr
 
   integer ifileo 
   real(4),allocatable,dimension(:,:)    :: rdiag_m2
   character(8),allocatable,dimension(:) :: cdiag
   real(4),dimension(nlev) :: plev,plev2,plev_ctr
   character(8) :: stid
   character(3) ::  subtype
   character(ifileo) :: fileo 

   character(30) :: files,filegrad
   character(10) :: levcard 

   integer(4):: isubtype
   integer i,j,k,ctr,obs_ctr
   integer ilat,ilon,ipres,itime,iweight,ndup

   integer nobs,nreal,nflag0,nlev,nlev0,getpres,iscater,igrads,nreal_m2
   real*4 rtim,xlat0,xlon0,rlat,rlon,hint

   nflag0=0
   rtim=0.0
   xlat0=0.0
   xlon0=0.0
   nlev0=0
   stid='        '
   plev2=plev-hint
   plev_ctr=0.0

   print *, '--> BEGIN grads_lev.x'  
   print *, 'nobs=',nobs
   print *, 'fileo=',fileo
   print *, 'nreal=', nreal


   if( nobs > 0 ) then

      allocate(cdiag(nobs))

      nreal_m2 = nreal - 2
      allocate(rdiag_m2(nreal_m2,nobs))       ! this will contain rdiag except
                                              ! for the first 2 fields (type and
                                              ! subtype)

      !---------------------------------------------
      ! Retrieve data from the linked list and load
      !   into the cdiag and rdiag_m2 arrays
      !
!      print *, 'Associated(list)   = ', associated( list )
      obs_ctr = 0
      next => list

      do while ( associated( next ) == .TRUE. )
         ptr = transfer(list_get( next ), ptr)
         print *, 'node data:', ptr%p
         next => list_next( next )

         obs_ctr = obs_ctr + 1
         cdiag( obs_ctr ) = ptr%p%stn_id

         do i=3, nreal
            rdiag_m2(i-2, obs_ctr) = ptr%p%rdiag( i )
         end do
      end do

!      print *, 'obs_ctr (list) = ', obs_ctr

      filegrad=trim(fileo)//'_'//trim(subtype)//'_grads'
   
      print *, 'filegrad = ', filegrad


      if(iscater ==1) then
         print *, 'begin writing scatter data file'

         files=trim(fileo)//'_'//trim(subtype)//'.scater'
         open(51,file=files,form='unformatted')
         write(51) nobs,nreal_m2
         write(51) rdiag_m2

!         if( trim(fileo) == 'gps004' ) then
!            print *, nobs,nreal_m2
!            print *, rdiag_m2
!         endif
 
         close(51)

         print *, 'end writing scatter data file'
      endif


      if (igrads ==1 .AND. nobs > 0)  then 

         ilat      = idx_obs_lat -2        ! modified position of lat
         ilon      = idx_obs_lon -2        ! modified position of lon
         ipres     = idx_pres -2           ! modified position of pressure
         itime     = idx_time -2           ! modified position of relative time
         iweight   = idx_rwgt -2           ! modofied position of weight

         call rm_dups( rdiag_m2,nobs,nreal_m2,ilat,ilon,ipres,itime,iweight,ndup )

         print *, 'OPENING filegrad, nreal_m2 = ', filegrad, nreal_m2
         open(31,file=filegrad,form='unformatted',status='new')

         ctr=0
         do  i=1,nobs
            print *, 'iweight, i, rdiag_m2(iweight,i) = ', iweight, i, rdiag_m2(iweight, i)
            if(rdiag_m2(iweight,i) >0.0 ) then
               stid=cdiag(i)
               rlat=rdiag_m2(ilat,i)
               rlon=rdiag_m2(ilon,i)
               k=getpres(rdiag_m2(ipres,i),plev2,nlev)

               print *, 'stid, rlat, rlon, rtim, k = ', stid, rlat, rlon, rtim, k

               !==============================
               !  write out into grads file
               !
               if(k /=0) then
                  write(31) stid,rlat,rlon,rtim,1,0

                  !---------------------------------------------------------------
                  ! note this writes the rdiag_m2 record starting at station
                  ! elevation; lat and lon are written in the line above with
                  ! the station id info
                  print *, 'k, plev2(k), rdiag_m2(j,i) = ', k, plev2(k), (rdiag_m2(j,k),j=3,nreal_m2)
                  write(31) plev2(k),(rdiag_m2(j,i),j=3,nreal_m2)
                  ctr = ctr + 1
                  plev_ctr(k) = plev_ctr(k) + 1.0
               endif
            endif
         enddo

100 format(6e13.3)

         !==============================
         ! write the end of file marker
         stid='        '
         write(31) stid,xlat0,xlon0,rtim,nlev0,nflag0 
         close(31)

         print *, 'obs written to file = ', ctr

      else
         write(6,*) "No output file generated, nobs, igrads = ", nobs, igrads
      endif

      deallocate(rdiag_m2,cdiag)

   end if

   print *, 'Levels:'
   do i=1,nlev
      print *, '   i, plev2(i),plev_ctr(i) = ', i, plev2(i),plev_ctr(i)
   enddo
 
   print *, '<-- END grads_lev.x'  
   return 
end


!========================================================
! getpres
!
!   return the index to the pressure level array (plev) 
!     to which a given input level (p1) belongs
!
!   NOTE:  This function works through the level array
!	from high to low and uses a >= condition not ==.
!	So a level is a range here and not a discrete
!       value like some of the other executables. 
!========================================================
function getpres(p1,plev,nlevs)

   implicit none
  
   real*4 p1
   real*4,dimension(nlevs) :: plev
   integer getpres,ip,ii,nlevs

   getpres = 0
!   ip = int(p1)

   do ii=1,nlevs
      if( p1 >=plev(ii) ) then 
         getpres=ii
         return 
      endif
   enddo

   return 
end

  
