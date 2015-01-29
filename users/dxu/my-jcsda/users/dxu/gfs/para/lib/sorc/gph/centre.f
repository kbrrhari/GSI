      SUBROUTINE CENTRE(Z,IMAX,JMAX,DOTSGI,A,B,M,ZLIM,ICEN1,LPLMI,
     X                  IFLO,IFHI)
C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C SUBPROGRAM:  CENTRE        DESCRIPTIVE TITLE NOT PAST COL 70
C   PRGMMR: KRISHNA KUMAR        ORG: NP12    DATE: 1999-07-01
C
C ABSTRACT: DOCUMENTATION WILL BE ADDED LATER.
C
C PROGRAM HISTORY LOG:
C   ??-??-??  DICK SCHURR
C   93-04-07  LILLY            CONVERT SUBROUTINE TO FORTRAN 77
C   96-02-21  LIN              CONVERT SUBROUTINE TO CFT-77
C   96-07-22  LIN              TURN OFF PRINT STATEMENT
C 1999-07-01  KRISHNA KUMAR    ASSIGNED THE RIGHT VALUE FOR INDEF
C                              (FROM THE RANGE FUNCTION) FOR IBM
C                              AND CONVERTED THIS CODE FROM CRAY 
C                              TO IBM RS/6000
C
C USAGE:    CALL CENTRE( Z, IMAX, JMAX, DOTSGI, A, B, M, ZLIM, ICEN1,
C                        LPLMI, IFLO, IFHI )
C   INPUT ARGUMENT LIST:
C     INARG1   - GENERIC DESCRIPTION, INCLUDING CONTENT, UNITS,
C     INARG2   - TYPE.  EXPLAIN FUNCTION IF CONTROL VARIABLE.
C
C   OUTPUT ARGUMENT LIST:      (INCLUDING WORK ARRAYS)
C     WRKARG   - GENERIC DESCRIPTION, ETC., AS ABOVE.
C     OUTARG1  - EXPLAIN COMPLETELY IF ERROR RETURN
C     ERRFLAG  - EVEN IF MANY LINES ARE NEEDED
C
C   INPUT FILES:   (DELETE IF NO INPUT FILES IN SUBPROGRAM)
C     DDNAME1  - GENERIC NAME & CONTENT
C
C   OUTPUT FILES:  (DELETE IF NO OUTPUT FILES IN SUBPROGRAM)
C     DDNAME2  - GENERIC NAME & CONTENT AS ABOVE
C     FT06F001 - INCLUDE IF ANY PRINTOUT
C
C REMARKS: LIST CAVEATS, OTHER HELPFUL HINTS OR INFORMATION
C
C ATTRIBUTES:
C   LANGUAGE: F90
C   MACHINE:  IBM
C
C$$$
      COMMON/PUTARG/PUTHGT,PUTANG,IPRPUT(2),ITAPUT
      COMMON/ADJ2/XIDID,YJDID
C
      DIMENSION JTEXT(3)
      DIMENSION Z(IMAX,JMAX)
C
      CHARACTER*8   IFLO(5),IFHI(5)
      CHARACTER*12  LTEXT
      CHARACTER*12  MTEXT
      CHARACTER*4   LPLMI
      CHARACTER*4   IDECP
      INTEGER       M(2)
      INTEGER       ITYPE(2)
      CHARACTER*1   CDECP
C
      REAL   INDEF,KDEF1,KDEF2
C
C///  DATA IDECP/4H.   /
      DATA IDECP/'.   '/
      DATA CDECP/'.'/
C///  DATA ITEXT/3*0/
      DATA XIRRS/870./
      DATA ITYPE/0,0/
C///  DATA IMSK1/Z'FF000000'/
C///  DATA IMSK2/Z'FFFF0000'/
C///  DATA INDEF/Z'7FFFFFFF'/
      DATA IMSK1/Z'FFFFFFFFFF000000'/
      DATA IMSK2/Z'FFFFFFFFFFFF0000'/
      DATA INDEF   /1.0E307 /
C
C///  EQUIVALENCE(LTEXT,ITEXT(1))
C///  EQUIVALENCE(MTEXT,JTEXT(1))
C
C     (1),(2),(3)...Z(IMAX,JMAX) IS GIVEN GRIDPOINT SCALED DATA FIELD
C     (4) .....  DOTSGI IS DOTS PER GRID INTERVAL
C                    WHERE EACH DOT IS 1/100TH INCH ON VARIAN
C                    NEGATIVE DOTSGI SIGNALS MERC SRN HEMI OPTION
C     (5),(6) ...TRUE Z VALUE = (Z + A) * B
C                    WHERE A IS ADDITIVE AND B IS MULTIPLICATIVE CONST
C     (7) .....  M = NO. OF CHARACTERS DESIRED WHEN TRUE Z VALUE IS
C                    CONVERTED TO EBCDIC FOR CENTRAL VALUE
C     (8) .....  ZLIM = LOWER  LIMIT TO TRUE Z VALUE
C                    LESS THAN WHICH WE WILL IGNORE CENTERS.
C     (9) .....  ICEN1 IS OPTION SWITCH
C                    =1  NORMAL CENTER FORMATTED LABELS
C                    =2  BIG H AND L USING SUBROUTINE HILO
C                    =3  SAME AS =1 EXCEPT I IS DISPLACED TO RHS 2-PANEL
C                    =4  SAME AS =2 EXCEPT I IS DISPLACED TO RHS 2-PANEL
C     (10).....  LPLMI IS FORMAT SELECTOR FOR SUBROUTINE BIN2EB
C                    FOR CONVERTING TRUE Z VALUE TO EBCDIC E.G., 'A99'
C     (11).....  IFLO IS 5-WORD FORMAT STATEMENT FOR ENCODE OF LOW CENTR
C     (12).....  IFHI IS 5-WORD FORMAT STATEMENT FOR ENCODE OF HI CENTER
C
C     INITIALIZE FOR CENTER SEARCH
C
      IMIN=1
      JMIN=1
      IISFC=0
      IF(M(2).EQ.9) IISFC=1
      IF(M(2).EQ.9) M(2)=3
      N=8
      ICOR = 0
      JCOR = 0
      IF(ICEN1 .LE. 0) GO TO 900
      IF(ICEN1 .GT. 4) GO TO 900
      GO TO(6,9,7,8),ICEN1
    6 ICOR = SIGN((ABS(XIDID) + 0.5),XIDID)
      JCOR = SIGN((ABS(YJDID) + 0.5),YJDID)
      GO TO 9
    7 ICOR = XIDID + XIRRS + 0.5
      JCOR = SIGN((ABS(YJDID) + 0.5),YJDID)
      GO TO 9
    8 ICOR = XIRRS + 0.5
    9 CONTINUE
      IRESET = 0
      SCALE = DOTSGI
      IF(SCALE.LT.0) IRESET=1
      IF(SCALE.LT.0) SCALE=-SCALE
  10  ILOW=0
      IHIGH=0
      DO 100 J=JMIN,JMAX
      DO 100 I=IMIN,IMAX
C
C     TEST FOR BORDER VALUES.
C
      IF(I.LE.IMIN+1.OR.I.GE.IMAX-1) GO TO 100
      IF(J.LE.JMIN+1.OR.J.GE.JMAX-1) GO TO 100
C     TEST FOR UNDEFINED VALUES.
C
      IF(Z(I,J).EQ.INDEF) GO TO 100
      KDEF1=Z(I-1,J)
      KDEF2=Z(I+1,J)
      IF((KDEF1.EQ.INDEF).OR.(KDEF2.EQ.INDEF)) GO TO 100
      KDEF1=Z(I-1,J-1)
      KDEF2=Z(I-1,J+1)
      IF((KDEF1.EQ.INDEF).OR.(KDEF2.EQ.INDEF)) GO TO 100
      KDEF1=Z(I+1,J-1)
      KDEF2=Z(I+1,J+1)
      IF((KDEF1.EQ.INDEF).OR.(KDEF2.EQ.INDEF)) GO TO 100
      KDEF1=Z(I,J+1)
      KDEF2=Z(I,J-1)
      IF((KDEF1.EQ.INDEF).OR.(KDEF2.EQ.INDEF)) GO TO 100
C
C     TEST FOR LOW CENTER
C
      IF(Z(I,J).GE.Z(I+1,J)) GO TO 30
      IF(Z(I,J).GE.Z(I,J+1)) GO TO 30
      IF(Z(I,J).GT.Z(I,J-1)) GO TO 30
      IF(Z(I,J).GT.Z(I-1,J)) GO TO 30
      IF(Z(I,J).GE.Z(I-1,J+1)) GO TO 30
      IF(Z(I,J).GE.Z(I+1,J+1)) GO TO 30
      IF(Z(I,J).GT.Z(I-1,J-1)) GO TO 30
      IF(Z(I,J).GT.Z(I+1,J-1)) GO TO 30
C
C     FOUND LOW CENTER
C
      ITYPE(2)=1
      ILOW=ILOW+1
      GO TO 50
C
C     TEST FOR HIGH CENTER
C
  30  IF(Z(I,J).LE.Z(I+1,J)) GO TO 100
      IF(Z(I,J).LE.Z(I,J+1)) GO TO 100
      IF(Z(I,J).LT.Z(I,J-1)) GO TO 100
      IF(Z(I,J).LT.Z(I-1,J)) GO TO 100
      IF(Z(I,J).LE.Z(I-1,J+1)) GO TO 100
      IF(Z(I,J).LE.Z(I+1,J+1)) GO TO 100
      IF(Z(I,J).LT.Z(I-1,J-1)) GO TO 100
      IF(Z(I,J).LT.Z(I+1,J-1)) GO TO 100
C
C     FOUND HIGH CENTER
C
      ITYPE(2)=2
      IHIGH=IHIGH+1
C
C     CALCULATE MAX/MIN POSITION USING STIRLING METHOD(9 POINTS)
C
  50  ANUMI=(Z(I+1,J)-Z(I-1,J))
      ADENMI=2.0*(Z(I+1,J)-2.0*Z(I,J)+Z(I-1,J))
      IF(ABS(ANUMI).GT.0.5*(ABS(ADENMI))) GO TO 115
      DELI=-ANUMI/ADENMI
      XPOS=SCALE*((FLOAT(I)-1.0)+DELI)
      ANUMJ=(Z(I,J+1)-Z(I,J-1))
      ADENMJ=2.0*(Z(I,J+1)-2.0*Z(I,J)+Z(I,J-1))
      IF(ABS(ANUMJ).GT.0.5*(ABS(ADENMJ))) GO TO 115
      DELJ=-ANUMJ/ADENMJ
      YPOS=SCALE*((FLOAT(J)-1.0)+DELJ)
C
C     ADJUST MAX/MIN DATA VALUE USING STIRLING INTERPOLATION
C
      ZDELI=Z(I,J)+0.5*DELI*(Z(I+1,J)-Z(I-1,J))+0.5*DELI*DELI*(Z(I+1,J)
     X-2.0*(Z(I,J))+Z(I-1,J))
      ZDELIU=Z(I,J+1)+0.5*DELI*(Z(I+1,J+1)-Z(I-1,J+1))+0.5*DELI*DELI*
     X(Z(I+1,J+1)-2.0*Z(I,J+1)+Z(I-1,J+1))
      ZDELIL=Z(I,J-1)+0.5*DELI*(Z(I+1,J-1)-Z(I-1,J-1))+0.5*DELI*DELI*
     X(Z(I+1,J-1)-2.0*Z(I,J-1)+Z(I-1,J-1))
      ZDELJ=ZDELI+0.5*DELJ*(ZDELIU-ZDELIL)+0.5*DELJ*DELJ*(ZDELIU-2.0*
     XZDELI+ZDELIL)
      GO TO 60
  115 XPOS = SCALE * (FLOAT(I) - 1.0)
      YPOS = SCALE * (FLOAT(J) - 1.0)
      ZDELJ = Z(I,J)
      GO TO 60
   60 CONTINUE
      JCAL = YPOS + 0.5
      ICAL = XPOS + 0.5
      JCAL = JCAL + JCOR
      ICAL = ICAL + ICOR
      TRUVAL = (ZDELJ + A ) * B
      INTG = SIGN((ABS(TRUVAL) + 0.5),TRUVAL)
      IF(FLOAT(INTG) .LT. ZLIM) GO TO 100
      IF(IISFC.EQ.1) GO TO 95
      NCHAR = M(2)
      IF(ITYPE(2) .EQ. 2) GO TO 90
      IF(IRESET .EQ. 1 .AND. I .GE. 26) GO TO 91
C
C     ...FORMAT LOW CENTER...
C
   81 CONTINUE
C*    CALL BIN2EB(INTG,JTEXT,NCHAR,LPLMI)
      CALL BIN2EB(INTG,MTEXT,NCHAR,LPLMI)
C     PRINT *, ' CENTRE:INTG=',INTG,' NCH=',NCHAR,' MTEXT=',MTEXT
C///
C///  CALL GBYTES(MTEXT,JTEXT,0,32,0,4)
      N = 12
      WRITE(LTEXT,FMT=IFLO)MTEXT
C
C///  LTEXT(1:NCHAR) = MTEXT(1:NCHAR)
C///  LTEXT(NCHAR+1:NCHAR+1)= CHAR(0)
      GO TO 96
   90 CONTINUE
      IF(IRESET .EQ. 1 .AND. I .GE. 26) GO TO 81
C
C     ...FORMAT HIGH CENTER...
C
   91 CONTINUE
C*    CALL BIN2EB(INTG,JTEXT,NCHAR,LPLMI)
      CALL BIN2EB(INTG,MTEXT,NCHAR,LPLMI)
C///
C///  CALL GBYTES(MTEXT,JTEXT,0,32,0,4)
      N = 12
      WRITE(LTEXT,FMT=IFHI)MTEXT
C///  LTEXT(1:NCHAR) = MTEXT(1:NCHAR)
C///  LTEXT(NCHAR+1:NCHAR+1)= CHAR(0)
C     PRINT *, ' IN CENTRE, IFHI=',IFHI
C     PRINT *, ' LTEXT=', LTEXT,' MTEXT=', MTEXT
      GO TO 96
C
C     ... FORMAT PRECIP CENTER-SPECIAL CASE
C
  95  CONTINUE
      NCHAR=3
C*    CALL BIN2EB(INTG,JTEXT,NCHAR,LPLMI)
      CALL BIN2EB(INTG,MTEXT,NCHAR,LPLMI)
C///
      CALL GBYTES(MTEXT,JTEXT,0,32,0,4)
C*    IPUU=LAND(JTEXT(1),IMSK1)
C??   IPUU=IAND(JTEXT(1),IMSK1)
C*    IPTH=LAND(SHFTL(JTEXT(1),8),IMSK2)
C???  IPTH=IAND(ISHFT(JTEXT(1),8),IMSK2)
C??   WRITE(LTEXT(1:4),FMT='(A1,A1,A2)')IPUU,IDECP,IPTH
      LTEXT(1:1) = CDECP
      LTEXT(2:4) = MTEXT(1:3)
      CALL PUTLAB(ICAL,JCAL,PUTHGT,LTEXT,PUTANG,4,IPRPUT,ITAPUT)
      GO TO 100
   96 CONTINUE
      GO TO (97,99,97,99),ICEN1
   97 CONTINUE
      CALL PUTLAB(ICAL,JCAL,PUTHGT,LTEXT,PUTANG,N,IPRPUT,ITAPUT)
      GO TO 100
   99 CONTINUE
      CALL HILO(ICAL,JCAL,ITYPE,LTEXT)
      GO TO 100
  100 CONTINUE
      RETURN
  900 CONTINUE
      PRINT  911, ICEN1
  911 FORMAT(1H , 'ERROR RETURN FROM CENTRE. GIVEN ARGUMENT OUT-OF-RANGE
     X. ICEN1 =HEX', Z8)
      RETURN
      END
