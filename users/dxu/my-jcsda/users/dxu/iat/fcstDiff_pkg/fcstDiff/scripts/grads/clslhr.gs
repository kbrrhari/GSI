'reinit'
'open /tmp/wd23sm/pgb/pgb.ctls3'
'enable print ouths3.gr'
*
'run /wd5/wd51/wd51js/rgbset.gs'
'set display color white'
'clear'
*
'set t 1'
'set lev 1000 10'
'set grads off'
'set grid off'
'set lon 0 360'
'set lat -90 90'
'define fld=ave(cnvhr*86400,t=1,t=3)'
'define cm=ave(fld,lon=0,lon=360,-b)'
'define fld=ave(lrghr*86400,t=1,t=3)'
'define lm=ave(fld,lon=0,lon=360,-b)'
'define fld=ave(swhr*86400,t=1,t=3)'
'define sm=ave(fld,lon=0,lon=360,-b)'
'define fld=ave(lwhr*86400,t=1,t=3)'
'define im=ave(fld,lon=0,lon=360,-b)'
*
*
' set lon 0'
' set lat -90 90'
*'set zlog on'
*
*  convective heating
*
'set parea 1.0 5.5  4.5 7.5'
'set grads off'
'set gxout shaded'
'set clevs 1.0 2.0 3.0'
'set ccols 0 9 14' 
'd cm'
'set gxout contour'
'set cint 0.5 '
'set clab off'
'set ccolor 1'
'set grads off'
'd cm'
'set clab on'
'set clevs 0.5 1 2 3 4 5'
'set ccolor 1'
'set grads off'
'd cm'
*
'draw ylab Pressure (hPa)'
'set string 1 tl 4 0'
'set strsiz 0.1'
'draw string 1.0 7.70 (a)'
'set string 1 tr 4 0'
'set strsiz 0.1'
*'draw string 5.5 7.70 Rk=3'
'set string 1 tc 5 0'
'set strsiz 0.15'
'draw string 3.25 7.70 Convective Heating Rate (K/day)'
*'run /emcsrc3/wd23sm/scripts/cbarnew.gs 0.7 0 3.25 4.25'
*
'set parea 6.0 10.5  4.5 7.5'
*
*
*  Plotting Large-scale Heating
*
'set parea 6.0 10.5  4.5 7.5'
*
'set grads off'
'set gxout shaded'
'set clevs 1.0 2.0 3.0'
'set ccols 0 9 14' 
'd lm'
'set gxout contour'
'set clab off'
'set cint 0.5'
'set ccolor 1'
'set grads off'
'd lm'
'set clab on'
'set clevs 0 0.5, 1.0, 2.0, 3.0 '
'set ccolor 1'
'set grads off'
'd lm'
*
'set strsiz 0.1'
'set string 1 tl 4 0'
'draw string 6.0 7.70 (b)'
'set string 1 tr 4 0'
*'draw string 10.5 7.70 Rk=3'
'set string 1 tc 5 0'
'set strsiz 0.15'
'draw string 8.25 7.70 Large-scale Heating (K/day)'
*'run /emcsrc3/wd23sm/scripts/cbarnew.gs 0.7 0 8.25 4.25'
*
'set parea 1.0 5.5  1.0 4.0'
*
*  Plotting Solar heating 
*
'set grads off'
'set gxout shaded'
'set clevs 1, 1.5, 2'
'set ccols 0 9 14 5' 
'd sm'
'set gxout contour'
'set cint 0.25'
'set clab off'
'set ccolor 1'
'set grads off'
'd sm'
'set clab on'
'set clevs 0.5 1 1.5 2 2.5 '
'set ccolor 1'
'set grads off'
'd sm'
'draw ylab Pressure (hPa)'
'draw xlab Latitude'
*
'set strsiz 0.1'
'set string 1 tl 4 0'
'draw string 1.0 4.20 (c)'
'set string 1 tr 4 0'
*'draw string 5.5 4.20 Rk=3'
'set string 1 tc 5 0'
'set strsiz 0.15'
'draw string 3.25 4.20 Solar Heating (K/day)'
*'run /emcsrc3/wd23sm/scripts/cbarnew.gs 0.7 0 3.25 0.3'
*
*  Longwave  Heating
*
'set parea 6.0 10.5  1.0 4.0'
*
'set lev 1000 100'
'set zlog off'
'set grads off'
'set gxout shaded'
'set clevs -4 -3 -2'
'set ccols 10 14 9 0'
'd im'
'set gxout contour'
'set clab off'
'set cint 0.5'
'set ccolor 1'
'set grads off'
'd im'
'set clab on'
'set clevs -1 -2 -3 -4 '
'set ccolor 1'
'd im'
'draw xlab Latitude'
*
'set strsiz 0.1'
'set string 1 tl 4 0'
'draw string 6.0 4.20 (d)'
'set string 1 tr 4 0'
*'draw string 10.5 4.20 Rk=3'
'set string 1 tc 5 0'
'set strsiz 0.15'
'draw string 8.25 4.20 IR Heating (K/day)'
'set strsiz 0.2'
'set string 1 tc 6 0'
'draw string 5.5 8.0 JJA Mean : RAS V2 With DD'
*'run /emcsrc3/wd23sm/scripts/cbarnew.gs 0.7 0 8.25 0.3'
*
'print'
