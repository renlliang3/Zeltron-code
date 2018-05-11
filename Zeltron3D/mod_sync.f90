!***********************************************************************!
!                       The Zeltron code project.                       !
!***********************************************************************!
! Copyright (C) 2012-2015. Authors: Benoît Cerutti & Greg Werner        !
!                                                                       !
! This program is free software: you can redistribute it and/or modify  !
! it under the terms of the GNU General Public License as published by  !
! the Free Software Foundation, either version 3 of the License, or     !
! (at your option) any later version.                                   !
!                                                                       !
! This program is distributed in the hope that it will be useful,       !
! but WITHOUT ANY WARRANTY; without even the implied warranty of        !
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         !
! GNU General Public License for more details.                          !
!                                                                       !
! You should have received a copy of the GNU General Public License     !
! along with this program. If not, see <http://www.gnu.org/licenses/>.  !
!***********************************************************************!

MODULE MOD_SYNC

USE MOD_INPUT

IMPLICIT NONE

PRIVATE
PUBLIC :: SYNC               ! Synchrotron kernel with pitch angle alpha
PUBLIC :: FSYNC              ! Precalculated synchrotron kernel F(x)
PUBLIC :: GSYNC              ! Precalculated synchrotron kernel G(x)
PUBLIC :: LOG_INTERPOL       ! Interpol function in the log-log plane

 CONTAINS

!***********************************************************************
! Subroutine SYNC
! Calculation of the synchrotron kernel for a pitch angle alpha
!
! INPUT: photon energy e1 [in eV], magnetic field B [in Gauss],
! Lorentz factor of the electron gam, pitch angle alpha [rad]
! and the mass of the particles [g].
!
! OUTPUT: Synchrotron kernel kern=dN/dtde1 [ph/s/erg]
!***********************************************************************

SUBROUTINE SYNC(mass,kern,e1,B,gam,alpha)

IMPLICIT NONE

!!! INPUT/OUTPUT PARAMETERS !!!
DOUBLE PRECISION                         :: mass,e1,kern,B,gam,alpha
DOUBLE PRECISION                         :: x1(100),x1intK53(100),x2

!***********************************************************************

! Initialisation
kern=0d0

CALL FSYNC(x1,x1intK53)

IF (B*sin(alpha).NE.0d0) THEN

x2=e1*evtoerg*4d0*pi*mass*c/(3d0*h*e*B*gam*gam*sin(alpha))

kern=LOG_INTERPOL(x1intK53,x1,x2,100)

  ! Asymptotic formulae for x<<1 et x>>1
  IF (x2.LT.1d-6.or.x2.GT.20d0) THEN

    IF (x2.LT.1d-6) THEN
    ! for x<<1
      kern=2.1495285*x2**(1d0/3d0)
    ELSE
    ! for x>>1
      kern=sqrt(pi/2d0)*exp(-x2)*sqrt(x2)
    ENDIF

  ENDIF

kern=kern*sqrt(3d0)*e**(3d0)*B*sin(alpha)/(mass*c*c*h*e1*evtoerg)

ELSE
kern=0d0
END IF

END SUBROUTINE SYNC

!***********************************************************************
! Subroutine FSYNC
! Precalculated synchrotron kernel averaged over isotropic pitch angle
!
! INPUT: x1,x1intK53
!
! OUTPUT: x1,x1intK53
!***********************************************************************

SUBROUTINE FSYNC(x1,x1intK53)

IMPLICIT NONE

DOUBLE PRECISION                         :: x1(100),x1intK53(100)

!***********************************************************************

x1=[1.000000000000000E-006,1.185080297211958E-006,1.404415310839983E-006,&
    1.664344913979274E-006,1.972382365321769E-006,2.337431479711146E-006,&
    2.770043992688672E-006,3.282724558145690E-006,3.890292195032295E-006,&
    4.610308630730232E-006,5.463585922344638E-006,6.474788028695254E-006,&
    7.673143721430598E-006,9.093291441943042E-006,1.077628052465281E-005,&
    1.277075772699502E-005,1.513437336272916E-005,1.793544768281981E-005,&
    2.125494567058563E-005,2.518881733252163E-005,2.985077113084251E-005,&
    3.537556072374498E-005,4.192288001653537E-005,4.968197910997698E-005,&
    5.887713456972981E-005,6.977413213488398E-005,8.268794924811474E-005,&
    9.799185947080311E-005,1.161282219460118E-004,1.376212677784760E-004,&
    1.630922529216028E-004,1.932774155653010E-004,2.290492570824860E-004,&
    2.714417616594907E-004,3.216802835831666E-004,3.812169660759664E-004,&
    4.517727154595472E-004,5.353869439090540E-004,6.344765186111429E-004,&
    7.519056212497024E-004,8.910685371059391E-004,1.055987766789732E-003,&
    1.251430296519367E-003,1.483045387739222E-003,1.757527868880820E-003,&
    2.082811649211582E-003,2.468299048284192E-003,2.925132569748623E-003,&
    3.466516975142080E-003,4.108100967191674E-003,4.868429515176245E-003,&
    5.769479896800527E-003,6.837296950858798E-003,8.102745902650151E-003,&
    9.602404522545615E-003,1.137962040552782E-002,1.348576393234217E-002,&
    1.598171312907039E-002,1.893961334495499E-002,2.244496261191877E-002,&
    2.659908296304404E-002,3.152204914340976E-002,3.735615936760205E-002,&
    4.427004844605502E-002,5.246356217003877E-002,6.217353384926757E-002,&
    7.368062997280773E-002,8.731746286693928E-002,0.103478204846147,&
    0.122629981754031,0.145326375224165,0.172223423943389,0.204098586433693,&
    0.241873213471381,0.286639179708277,0.339690444281276,0.402560452668916,&
    0.477066460894660,0.565362063266901,0.669999441968706,0.794003137820118,&
    0.940957474555095,1.11511016360957,1.32149508411450,1.56607778704655,&
    1.85592792933017,2.19942362209458,2.60649359976684,3.08890420989276,&
    3.66059951911898,4.33810436609147,5.14100201150418,6.09250019176065,&
    7.22010193801562,8.55640055060418,10.1400217075746,12.0167399389482,&
    14.2408017383675,16.8764935566412,20.0000000000000]
    
x1intK53=[2.149740291554781E-002,2.274901841108215E-002,2.407347673895755E-02,&
    2.547501192814867E-002,2.695810311511616E-002,2.852748854769207E-002,&
    3.018818035452749E-002,3.194548011543796E-002,3.380499526832988E-002,&
    3.577265638843877E-002,3.785473537529143E-002,4.005786458201257E-002,&
    4.238905692024220E-002,4.485572697186294E-002,4.746571313581508E-002,&
    5.022730083430440E-002,5.314924679746723E-002,5.624080443877249E-002,&
    5.951175032481285E-002,6.297241173226253E-002,6.663369527122917E-002,&
    7.050711653745867E-002,7.460483073522131E-002,7.893966418747039E-002,&
    8.352514661910548E-002,8.837554406184385E-002,9.350589218401047E-002,&
    9.893202979401500E-002,0.104670632200595,0.110739244033946,&
    0.117156311037122,0.123941210223590,0.131114277661013,0.138696832979062,&     
    0.146711199505309,0.155180718702228,0.164129757302985,0.173583705215995,&     
    0.183568961878227,0.194112908273776,0.205243861283644,0.216991006379192,&     
    0.229384303896832,0.242454363213354,0.256232278054607,0.270749414885549,&     
    0.286037144813124,0.302126507646095,0.319047794653951,0.336830034101253,&
    0.355500360750710,0.375083247170932,0.395599570795967,0.417065486209677,&     
    0.439491067027217,0.462878676000437,0.487221015609695,0.512498804519786,&     
    0.538678018088907,0.565706624027361,0.593510737989999,0.621990119460058,&  
    0.651012927475406,0.680409661204000,0.709966226034660,0.739416097466217,&     
    0.768431610877948,0.796614496726025,0.823485923402867,0.848476524260903,&     
    0.870917196368038,0.890031895276086,0.904934240857714,0.914630512970876,&     
    0.918032544174628,0.913985044579456,0.901312851526806,0.878894144928416,&     
    0.845765223343403,0.801260109434639,0.745182884585394,0.678001036863573,&     
    0.601033606171899,0.516589597155386,0.427994417761062,0.339434248068025,&     
    0.255564108478843,0.180878805791705,0.118939475992646,&
    7.165783884585139E-002,3.890601404389666E-002,1.866644749682380E-002,&
    7.731985450943564E-003,2.689821816878248E-003,7.606072676721128E-004,&
    1.681815907755760E-004,2.777448106239215E-005,3.244518011577780E-006,&
    2.513722787179256E-007,1.196759294412181E-008]

END SUBROUTINE FSYNC

!***********************************************************************
! Subroutine GSYNC
! Precalculated synchrotron kernel G(x)=x*K_{2/3}(x)
!
! INPUT: x1,x1K23
!
! OUTPUT: x1,x1K23
!***********************************************************************

SUBROUTINE GSYNC(x1,x1K23)

IMPLICIT NONE

DOUBLE PRECISION                         :: x1(100),x1K23(100)

!***********************************************************************

x1=[1.000000000000000E-006,1.185080297211958E-006,1.404415310839983E-006,&
    1.664344913979274E-006,1.972382365321769E-006,2.337431479711146E-006,&
    2.770043992688672E-006,3.282724558145690E-006,3.890292195032295E-006,&
    4.610308630730232E-006,5.463585922344638E-006,6.474788028695254E-006,&
    7.673143721430598E-006,9.093291441943042E-006,1.077628052465281E-005,&
    1.277075772699502E-005,1.513437336272916E-005,1.793544768281981E-005,&
    2.125494567058563E-005,2.518881733252163E-005,2.985077113084251E-005,&
    3.537556072374498E-005,4.192288001653537E-005,4.968197910997698E-005,&
    5.887713456972981E-005,6.977413213488398E-005,8.268794924811474E-005,&
    9.799185947080311E-005,1.161282219460118E-004,1.376212677784760E-004,&
    1.630922529216028E-004,1.932774155653010E-004,2.290492570824860E-004,&
    2.714417616594907E-004,3.216802835831666E-004,3.812169660759664E-004,&
    4.517727154595472E-004,5.353869439090540E-004,6.344765186111429E-004,&
    7.519056212497024E-004,8.910685371059391E-004,1.055987766789732E-003,&
    1.251430296519367E-003,1.483045387739222E-003,1.757527868880820E-003,&
    2.082811649211582E-003,2.468299048284192E-003,2.925132569748623E-003,&
    3.466516975142080E-003,4.108100967191674E-003,4.868429515176245E-003,&
    5.769479896800527E-003,6.837296950858798E-003,8.102745902650151E-003,&
    9.602404522545615E-003,1.137962040552782E-002,1.348576393234217E-002,&
    1.598171312907039E-002,1.893961334495499E-002,2.244496261191877E-002,&
    2.659908296304404E-002,3.152204914340976E-002,3.735615936760205E-002,&
    4.427004844605502E-002,5.246356217003877E-002,6.217353384926757E-002,&
    7.368062997280773E-002,8.731746286693928E-002,0.103478204846147,&
    0.122629981754031,0.145326375224165,0.172223423943389,0.204098586433693,&
    0.241873213471381,0.286639179708277,0.339690444281276,0.402560452668916,&
    0.477066460894660,0.565362063266901,0.669999441968706,0.794003137820118,&
    0.940957474555095,1.11511016360957,1.32149508411450,1.56607778704655,&
    1.85592792933017,2.19942362209458,2.60649359976684,3.08890420989276,&
    3.66059951911898,4.33810436609147,5.14100201150418,6.09250019176065,&
    7.22010193801562,8.55640055060418,10.1400217075746,12.0167399389482,&
    14.2408017383675,16.8764935566412,20.0000000000000]
    
x1K23=[1.0747643897745062E-02,1.1373545210783379E-02,1.2035896592231921E-02,&
       1.2736820749913969E-02,1.3478564008782041E-02,1.4263503509513454E-02,&
       1.5094154826196853E-02,1.5973180027474308E-02,1.6903396206909029E-02,&
       1.7887784509830962E-02,1.8929499685476209E-02,2.0031880194881776E-02,&
       2.1198458906729667E-02,2.2432974415152813E-02,2.3739383015421545E-02,&
       2.5121871375423030E-02,2.6584869942922768E-02,2.8133067130752962E-02,&
       2.9771424324296393E-02,3.1505191757913456E-02,3.3339925309272031E-02,&
       3.5281504262853688E-02,3.7336150096185156E-02,3.9510446344517433E-02,&
       4.1811359601670921E-02,4.4246261716466256E-02,4.6822953245424861E-02,&
       4.9549688223044487E-02,5.2435200310667798E-02,5.5488730383404079E-02,&
       5.8720055611260404E-02,6.2139520084949121E-02,6.5758067027916547E-02,&
       6.9587272622869414E-02,7.3639381461965511E-02,7.7927343602935212E-02,&
       8.2464853176107314E-02,8.7266388436226042E-02,9.2347253083557665E-02,&
       9.7723618585195612E-02,1.0341256710191914E-01,1.0943213445827858E-01,&
       1.1580135237047884E-01,1.2254028885076103E-01,1.2967008531576230E-01,&
       1.3721298841045385E-01,1.4519237388080361E-01,1.5363275893842104E-01,&
       1.6255979839644882E-01,1.7200025833790941E-01,1.8198195910426676E-01,&
       1.9253367683570879E-01,2.0368498949697711E-01,2.1546604908839945E-01,&
       2.2790725633507314E-01,2.4103880728814336E-01,2.5489007263888469E-01,&
       2.6948875978360587E-01,2.8485979441901821E-01,3.0102384236008223E-01,&
       3.1799537313269710E-01,3.3578014472089196E-01,3.5437196411308958E-01,&
       3.7374855224180692E-01,3.9386631705642655E-01,4.1465381928802320E-01,&
       4.3600370938982375E-01,4.5776293286262165E-01,4.7972106230544437E-01,&
       5.0159674344171334E-01,5.2302247393686374E-01,5.4352831324898032E-01,&
       5.6252570297275262E-01,5.7929341614688590E-01,5.9296879293422222E-01,&
       6.0254885612078724E-01,6.0690753191603164E-01,6.0483674932169196E-01,&
       5.9512008984440556E-01,5.7664695249016851E-01,5.4857149882323297E-01,&
       5.1051228601562937E-01,4.6277410354308585E-01,4.0655319823184477E-01,&
       3.4406425214049335E-01,2.7851101631629366E-01,2.1382723252770189E-01,&
       1.5415740709436007E-01,1.0313621159571919E-01,6.3142610234701455E-02,&
       3.4793456825950260E-02,1.6920308680868815E-02,7.0950242834264222E-03,&
       2.4955701251498405E-03,7.1265991922884824E-04,1.5896437702472136E-04,&
       2.6456199476679287E-05,3.1116648932472386E-06,2.4252957578827992E-07,&
       1.1607696861888819E-08]

END SUBROUTINE GSYNC

!***********************************************************************
! Function LOG_INTERPOL: linear interpolation
! INPUT: fun (function to interpolate), xi (initial grid where fun is
! defined), and xf (final grid).
! OUTPUT: LOG_INTERPOL (fun calculated in the xf grid)
!***********************************************************************

FUNCTION LOG_INTERPOL(fun,xi,xf,n_xi)

IMPLICIT NONE

!!! INPUT/OUTPUT PARAMETERS !!!
INTEGER                                  :: n_xi
DOUBLE PRECISION, DIMENSION(1:n_xi)      :: fun,xi,mind
DOUBLE PRECISION                         :: xf,log_interpol

!!! Intermediate variables !!!
DOUBLE PRECISION                         :: xp,diff,ly1,ly0,lh,lf1,lf0,lp

!!! Loop indexes !!!
INTEGER                                  :: j

!***********************************************************************

  IF (xf.LT.minval(xi).OR.xf.GT.maxval(xi)) THEN
    log_interpol=0.0
  ELSE

  mind=minloc(abs(xf-xi))
  j=mind(1)

  ly1=log10(xi(j+1))
  ly0=log10(xi(j))
  lh=ly1-ly0
  lf1=log10(fun(j+1))
  lf0=log10(fun(j))
  lp=(log10(xf)-ly0)/lh
  ! Linear interpolation in the log-log plane
  log_interpol=1d1**((1d0-lp)*lf0+lp*lf1)

  ENDIF

END FUNCTION LOG_INTERPOL

!***********************************************************************

END MODULE MOD_SYNC
