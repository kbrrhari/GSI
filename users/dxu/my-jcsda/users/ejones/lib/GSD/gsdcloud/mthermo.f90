!
!$$$  subprogram documentation block
!                .      .    .                                       .
! ABSTRACT: 
!  This file collects subroutines and functions related to thermodynamic calculations
!
! PROGRAM HISTORY LOG:
!    2009-01-20  Hu  Add NCO document block
!    2010-05-03  Hu  Clean the code
!
!
!   input argument list:
!
!   output argument list:
!
! USAGE:
!   INPUT FILES: 
!
!   OUTPUT FILES:
!
! REMARKS:
!
! ATTRIBUTES:
!   LANGUAGE: FORTRAN 90 
!   MACHINE:  Linux cluster (WJET)
!
!$$$
!
!_____________________________________________________________________
!
  FUNCTION esat(t)
!
!   this function returns the saturation vapor pressure over
!   water (mb) given the temperature (celsius).
!   the algorithm is due to nordquist, w.s.,1973: "numerical approxima-
!   tions of selected meteorlolgical parameters for cloud physics prob-
!   lems," ecom-5475, atmospheric sciences laboratory, u.s. army
!   electronics command, white sands missile range, new mexico 88002.

  tk = t+273.15
  p1 = 11.344-0.0303998*tk
  p2 = 3.49149-1302.8844/tk
  c1 = 23.832241-5.02808*ALOG10(tk)
  esat = 10.**(c1-1.3816E-7*10.**p1+8.1328E-3*10.**p2-2949.076/tk)
  RETURN
  END FUNCTION esat

  FUNCTION eslo(t)
!
!   this function returns the saturation vapor pressure over liquid
!   water eslo (millibars) given the temperature t (celsius). the
!   formula is due to lowe, paul r.,1977: an approximating polynomial
!   for the computation of saturation vapor pressure, journal of applied
!   meteorology, vol 16, no. 1 (january), pp. 100-103.
!   the polynomial coefficients are a0 through a6.
  use kinds, only: r_single,i_kind,r_kind
  IMPLICIT NONE
!
  real(r_kind), intent(in) :: t
  real(r_kind) :: eslo
  
  real(r_kind) :: a0,a1,a2,a3,a4,a5,a6
  real(r_kind) :: es

  DATA a0,a1,a2,a3,a4,a5,a6                                             &
      /6.107799961,     4.436518521E-01, 1.428945805E-02,               &
      2.650648471E-04, 3.031240396E-06, 2.034080948E-08,                &
      6.136820929E-11/
  es = a0+t*(a1+t*(a2+t*(a3+t*(a4+t*(a5+a6*t)))))
  IF (es < 0.) es = 0.
  eslo = es
  RETURN
  END FUNCTION eslo

  FUNCTION tda(o,p)
!
!   this function returns the temperature tda (celsius) on a dry adiabat
!   at pressure p (millibars). the dry adiabat is given by
!   potential temperature o (celsius). the computation is based on
!   poisson's equation.

  tda= (o+273.15)*((p*.001)**.286)-273.15
  RETURN
  END FUNCTION tda

  FUNCTION tmr(w,p)
!
!   this function returns the temperature (celsius) on a mixing
!   ratio line w (g/kg) at pressure p (mb). the formula is given in
!   table 1 on page 7 of stipanuk (1973).
!
!   initialize constants

  DATA c1/.0498646455/,c2/2.4082965/,c3/7.07475/
  DATA c4/38.9114/,c5/.0915/,c6/1.2035/

  x= ALOG10(w*p/(622.+w))
  tmrk= 10.**(c1*x+c2)-c3+c4*((10.**(c5*x)-c6)**2.)
  tmr= tmrk-273.15
  RETURN
  END FUNCTION tmr

  FUNCTION tsa(os,p)
!
!   this function returns the temperature tsa (celsius) on a saturation
!   adiabat at pressure p (millibars). os is the equivalent potential
!   temperature of the parcel (celsius). sign(a,b) replaces the
!   algebraic sign of a with that of b.
!   b is an empirical constant approximately equal to 0.001 of the latent
!   heat of vaporization for water divided by the specific heat at constant
!   pressure for dry air.

  DATA b/2.6518986/
  a= os+273.15

!   tq is the first guess for tsa.

  tq= 253.15

!   d is an initial value used in the iteration below.

  d= 120.

!   iterate to obtain sufficient accuracy....see table 1, p.8
!   of stipanuk (1973) for equation used in iteration.

  DO i= 1,12
    tqk= tq-273.15
    d= d/2.
    x= a*EXP(-b*w(tqk,p)/tq)-tq*((1000./p)**.286)
    IF (ABS(x) < 1E-7) GOTO 2
    tq= tq+SIGN(d,x)
  END DO
2 tsa= tq-273.15
  RETURN
  END FUNCTION tsa

  FUNCTION tw(t,td,p)
!   this function returns the wet-bulb temperature tw (celsius)
!   given the temperature t (celsius), dew point td (celsius)
!   and pressure p (mb).  see p.13 in stipanuk (1973), referenced
!   above, for a description of the technique.
!
!
!   determine the mixing ratio line thru td and p.

  aw = w(td,p)
!
!   determine the dry adiabat thru t and p.

  ao = (t+273.15)*((1000./p)**.286)-273.15
  pi = p

!   iterate to locate pressure pi at the intersection of the two
!   curves .  pi has been set to p for the initial guess.

  DO i= 1,10
    x= .02*(tmr(aw,pi)-tda(ao,pi))
    IF (ABS(x) < 0.01) EXIT
    pi= pi*(2.**(x))
  END DO

!   find the temperature on the dry adiabat ao at pressure pi.

  ti= tda(ao,pi)

!   the intersection has been located...now, find a saturation
!   adiabat thru this point. function os returns the equivalent
!   potential temperature (c) of a parcel saturated at temperature
!   ti and pressure pi.

  aos= (ti+273.15)*((1000./pi)**.286)*(EXP(2.6518986*w(ti,pi)/(ti+273.15)))-273.15

!   function tsa returns the wet-bulb temperature (c) of a parcel at
!   pressure p whose equivalent potential temperature is aos.

  tw = tsa(aos,p)
  RETURN
  END FUNCTION tw

  FUNCTION w(t,p)
!
!  this function returns the mixing ratio (grams of water vapor per
!  kilogram of dry air) given the dew point (celsius) and pressure
!  (millibars). if the temperture  is input instead of the
!  dew point, then saturation mixing ratio (same units) is returned.
!  the formula is found in most meteorological texts.

  w= 622.*esat(t)/(p-esat(t))
  RETURN
  END FUNCTION w
