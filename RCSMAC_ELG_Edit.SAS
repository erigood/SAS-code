%*--------------------------------------------------------------------;
%*                                                                    ;
%*            SAS-Macro RCS                                           ;
%*            =============                                           ;
%*                                                                    ;
%* TITLE:     Cox Regression with Restricted Cubic Splines            ;
%* AUTHORS:   Harald HEINZL, Alexandra KAIDER                         ;
%*            Department of Medical Computer Sciences                 ;
%*            University of Vienna, Austria                           ;
%*            Spitalgasse 23, A-1090 Vienna, Austria                  ;
%* VERSION:   Version 2.0                                             ;
%* DATE:      September 1996                                          ;
%* COMMENTS:  The macro generates a SAS program for Cox regression    ;
%*            and graphical output including 95 %-confidence bands    ;
%*--------------------------------------------------------------------;
%*                                                                    ;
%* HOW TO USE THE SAS-MACRO RCS:                                      ;
%* =============================                                      ;
%*                                                                    ;
%* TITLE              title of the analysis                           ;
%* DATA               SAS data set, default is DATA                   ;
%* DIRDATA            input directory which contains the SAS data     ;
%*                    set, default is 'c:\user\data'                  ;
%* PROGRAM            external filename of the program file, default  ;
%*                    is 'c:\user\__prog.sas', note that both         ;
%*                    directory and filename have to be specified     ;
%* TIME               survivaltime                                    ;
%* STATUS             status (0=censored, non-zero=failure)           ;
%* COV1 - COV20       names for the covariates (MAXIMUM: 20)          ;
%* WHAT1 - WHAT20     specifies what should happen with COV1-COV20    ;
%*                    0 ... non-linear modelling                      ;
%*                    1 ... time by covariate interaction             ;
%*                    2 ... time by binary time dependent covariate   ;
%*                          interaction                               ;
%*                    otherwise ... ordinary covariate (default)      ;
%* KNOTS1-KNOTS20     knot-positions for the splines, use blanks as   ;
%*                    delimiter, specify in strictly increasing order ;
%* GRAPH              either the relative hazard ratio function (HR)  ;
%*                    or its logarithm (LR) or both (BOTH) will be    ;
%*                    plotted, default is LR                          ;
%* TIMEUNIT           label for the X-axis, if it is the time-axis,   ;
%*                    that is if WHATn=1 or 2 (default: MONTHS)       ;
%*--------------------------------------------------------------------;

%MACRO RCS
(TITLE=, DATA=DATA, DIRDATA=%STR(C:\USER\DATA\),   
 PROGRAM=%STR(C:\USER\__PROG.SAS), TIME=, STATUS=,
 COV1=,    COV2=,    COV3=,    COV4=,    COV5=,
 COV6=,    COV7=,    COV8=,    COV9=,    COV10=,
 COV11=,   COV12=,   COV13=,   COV14=,   COV15=,
 COV16=,   COV17=,   COV18=,   COV19=,   COV20=,
 WHAT1=,   WHAT2=,   WHAT3=,   WHAT4=,   WHAT5=,
 WHAT6=,   WHAT7=,   WHAT8=,   WHAT9=,   WHAT10=,
 WHAT11=,  WHAT12=,  WHAT13=,  WHAT14=,  WHAT15=,
 WHAT16=,  WHAT17=,  WHAT18=,  WHAT19=,  WHAT20=,
 KNOTS1=,  KNOTS2=,  KNOTS3=,  KNOTS4=,  KNOTS5=,
 KNOTS6=,  KNOTS7=,  KNOTS8=,  KNOTS9=,  KNOTS10=,
 KNOTS11=, KNOTS12=, KNOTS13=, KNOTS14=, KNOTS15=,
 KNOTS16=, KNOTS17=, KNOTS18=, KNOTS19=, KNOTS20=,
 GRAPH=LR, TIMEUNIT=MONTHS);

%LOCAL CZ I J FLEX;

*----------------------------------------------------------------------;
*------------Extracting information from the macro statements----------;
*----------------------------------------------------------------------;

%LET CZ=0;        %* counting the number of covariates;
%DO I=1 %TO 20;
  %IF &&COV&I NE %THEN %LET CZ=&I;
  %ELSE %GOTO WEITER;
%END;

%WEITER:
%LOCAL %NAMES(&CZ);

%DO I=1 %TO &CZ;
  %LET K&I=%WORDS(&&KNOTS&I);  
  %IF ((&&WHAT&I NE 0) OR (&&K&I LE 1)) AND (&&WHAT&I NE 1) 
  AND (&&WHAT&I NE 2) %THEN %DO; %LET WHAT&I=; %LET K&I=0; %END; 
%END;

*---------------------------------------------------------------------;
*---------------------Calculation of hazard ratios--------------------;
*---------------------------------------------------------------------;

FILENAME CC "&PROGRAM" RECFM=V LRECL=70;

DATA _NULL_; IF _N_=1; FILE CC;

PUT "LIBNAME __DATA  '&DIRDATA'; ";
PUT " ";
%IF &TITLE NE %THEN %DO; PUT "TITLE ' &TITLE '; "; %END;
%ELSE %DO; PUT "TITLE; "; %END;
PUT " ";
PUT "PROC PHREG DATA=__DATA.&DATA COVOUT OUTEST=__RCS; ";
PUT " MODEL &TIME*&STATUS(0) = " @ ;
%DO I=1 %TO &CZ;
  %IF &&WHAT&I NE 2 %THEN %DO; PUT " &&COV&I " @ ; %END;
  %ELSE                   %DO; PUT " __&I._INT " @ ; %END;
  %IF (&&WHAT&I EQ 1) OR ((&&WHAT&I EQ 2) AND (&&K&I GE 2)) %THEN %DO; 
    PUT " __&I._LIN " @ ; 
  %END;
  %DO J=1 %TO %EVAL(&&K&I-2);
    PUT " __&I._&J " @ ;
  %END;
%END;
PUT " /RL; " ;
%DO I=1 %TO &CZ;
  %IF &&WHAT&I NE %THEN %DO;
    %IF &&K&I GT 2 %THEN %LET FLEX=spline;
    %ELSE %DO;
      %IF (&&WHAT&I EQ 2) AND (&&K&I LT 2) %THEN %LET FLEX=constant;
      %ELSE %LET FLEX=linear;
    %END;
    PUT " ";
    %IF &&WHAT&I EQ 0 %THEN %DO;
      PUT " ********** &FLEX modelling of fixed covariate &&COV&I; ";
      %IF &&K&I GT 2 %THEN %DO;
        PUT " ********** with &&K&I knots located at; ";
        PUT " ********** &&KNOTS&I; "; 
      %END;
      %IF %QSUBSTR(%QSCAN(&&KNOTS&I,1,%STR( )),1,1) EQ %QUOTE(-) 
      %THEN %RCUBSPL(&I,&&K&I,&&KNOTS&I,&&COV&I,WSTAT=1,WM=0);
      %ELSE %RCUBSPL(&I,&&K&I,&&KNOTS&I,&&COV&I,WSTAT=1);
    %END;
    %ELSE %DO;
      %IF &&WHAT&I EQ 1 %THEN %DO;
        PUT " ********** &FLEX modelling of the time-dependent effect;";
        PUT " ********** of fixed covariate &&COV&I; ";
        %IF &&K&I GT 2 %THEN %DO;
          PUT " ********** with &&K&I knots located at; ";
          PUT " ********** &&KNOTS&I; "; 
        %END;
        %RCUBSPL(&I,&&K&I,&&KNOTS&I,&TIME);
        PUT " __&I._LIN=&&COV&I*&TIME; ";
        %DO J=1 %TO %EVAL(&&K&I-2); 
          PUT " __&I._&J=&&COV&I*__&I._&J; ";
        %END; 
      %END;
      %ELSE %DO;   %* WHAT=2;
        PUT " ********** &FLEX modelling of the time-dependent effect;";
        PUT " ********** of binary time-dependent covariate &&COV&I; ";
        %IF &&K&I GT 2 %THEN %DO;
          PUT " ********** with &&K&I knots located at; ";
          PUT " ********** &&KNOTS&I; "; 
        %END;
        PUT " IF &TIME>=&&COV&I AND &&COV&I>.Z ";
        %IF &&K&I GE 2 %THEN %DO; 
          PUT "   THEN DO; __&I._LIN=&TIME-&&COV&I; __&I._INT=1; END; ";
          PUT "   ELSE DO; __&I._LIN=0; __&I._INT=0; END; ";
          %RCUBSPL(&I,&&K&I,&&KNOTS&I,__&I._LIN);
        %END;
        %ELSE %DO; 
          PUT "   THEN __&I._INT=1; ELSE __&I._INT=0; ";
        %END;
      %END;
    %END;
  %END;
%END;

%*---------------------------------------------------------------;
%*-------------------------Tests---------------------------------;
%*---------------------------------------------------------------;
%DO I=1 %TO &CZ;
  %IF ((&&WHAT&I EQ 0) AND (&&K&I GT 2)) OR (&&WHAT&I EQ 1) OR
  ((&&WHAT&I EQ 2) AND (&&K&I GE 2)) %THEN %DO;
    PUT " ";
    PUT " *--------- Testing variable: &&COV&I ---------; ";     	
    PUT " EFFECT&I: TEST " @;	 
    %IF &&WHAT&I NE 2 %THEN %DO; PUT " &&COV&I" @ ; %END;
    %ELSE                   %DO; PUT " __&I._INT" @; %END;
    %IF &&WHAT&I NE 0 %THEN %DO; PUT ", __&I._LIN" @ ; %END;
    %DO J=1 %TO %EVAL(&&K&I-2);
      PUT ", __&I._&J" @ ;
    %END;
    PUT ";" ;
    %IF &&WHAT&I NE 0 %THEN %DO;	 
      PUT " NONCON&I: TEST  __&I._LIN" @ ;
      %DO J=1 %TO %EVAL(&&K&I-2);
        PUT ", __&I._&J" @ ;
      %END;
      PUT ";" ;
    %END;
    %IF &&K&I GT 2 %THEN %DO;
      PUT " NONLIN&I: TEST  __&I._1" @ ;
      %DO J=2 %TO %EVAL(&&K&I-2);
        PUT ", __&I._&J" @ ;
      %END;
      PUT ";" ;
    %END;
  %END;
%END;
PUT " RUN; " ;
PUT "*==================== End of PROC PHREG ====================;" ;
PUT " ";

*--------------------------------------------------------------------;
*------Second part: confidence-bands and graphical output------------;
*--------------------------------------------------------------------;

%DO I=1 %TO &CZ;
  %IF (&&WHAT&I NE) AND (&&K&I GE 1) %THEN %DO;
    PUT "*-------------------- Graph for &&COV&I --------------------;";
    PUT "PROC IML; ";
    PUT " NPOINTS=101;   * Number of points to build the graphic;";  
    %IF &&WHAT&I EQ 0 %THEN %DO;  
      %RCUBSPL(&I,&&K&I,&&KNOTS&I,X,WSTAT=2,WM=REF);
      PUT " XMAT=(X-REF)" @ ;
    %END;
    %ELSE %DO; 
      %RCUBSPL(&I,&&K&I,&&KNOTS&I,X,WSTAT=2);
      PUT " XMAT=J(NPOINTS,1,1)" @ ;
      %IF (&&WHAT&I EQ 1) OR (&&K&I GE 2) %THEN %DO;
        PUT "||X" @ ;
      %END;
    %END;    
    %DO J=1 %TO (&&K&I - 2);
      PUT "||S&J" @ ;
    %END;
    PUT ";";
    PUT " HV={" @ ;
    %IF &&WHAT&I NE 2 %THEN %DO; PUT " &&COV&I" @ ; %END;
    %ELSE                   %DO; PUT " __&I._INT" @ ; %END;
    %IF (&&WHAT&I EQ 1) OR ((&&WHAT&I EQ 2) AND (&&K&I GE 2)) %THEN %DO;
      PUT " __&I._LIN" @ ;
    %END; 
    %DO J=1 %TO (&&K&I - 2);
      PUT " __&I._&J" @ ;
    %END;
    PUT " }; ";
    PUT " USE __RCS;  READ ALL VAR HV INTO C; ";
    PUT " READ ALL VAR { _NAME_ } INTO HC;  CLOSE __RCS; ";
    PUT " B=C[1,]` ;  HC=REPEAT(HC,1,NCOL(HV)); ";
    PUT " HV=REPEAT(HV,NROW(HC),1); ";
    PUT " HV=(upcase(HC)=upcase(HV))[,+]; ";
    PUT " HV=LOC(HV#(1:NROW(C))`);  C=C[HV,]; ";
    PUT " F=XMAT*B; FU=XMAT*C*XMAT`; FREE XMAT;";
    PUT " FU=SQRT(VECDIAG(FU));  FO=F+1.96*FU;  FU=F-1.96*FU; ";
    PUT " Z=J(NROW(F),1,1)//J(NROW(F),1,2)//J(NROW(F),1,3); ";
    PUT " F=F//FO//FU; FE=EXP(F);  X=REPEAT(X,3,1); ";
    PUT " CREATE __RCS&I VAR { F FE Z X };  APPEND;  CLOSE __RCS&I; ";
    PUT " QUIT; ";
    PUT " ";
    PUT " SYMBOL1 C=RED  L=1 I=JOIN WIDTH=3; ";
    PUT " SYMBOL2 C=BLUE L=2 I=JOIN WIDTH=3; ";
    PUT " SYMBOL3 C=BLUE L=2 I=JOIN WIDTH=3; ";

	%let fc = Knots used at &KNOTS1.;
	%let footnote_comment= %STR(%')&fc.%STR(%');
	PUT " footnote &footnote_comment. ; ";
	%let oc =&output.\&TITLE..pdf;
	%let output_comment = %STR(%')&oc.%STR(%');
	PUT " ods pdf file = &output_comment. ; ";

    %IF %UPCASE(&GRAPH) EQ LR OR %UPCASE(&GRAPH) EQ BOTH %THEN 
      %RGRA(0,&I,&&COV&I,&&WHAT&I,&TIMEUNIT);  
    %IF %UPCASE(&GRAPH) EQ HR OR %UPCASE(&GRAPH) EQ BOTH %THEN 
      %RGRA(1,&I,&&COV&I,&&WHAT&I,&TIMEUNIT);
  %END;
%END; 
run; %* closes the DATA _NULL_ step;
%MEND RCS;


%*Generating a list of names (SAS macro manual, p.255);
%MACRO NAMES (NUMBER, PREFIX=K);
  %LOCAL I;
  %DO I=1 %TO &NUMBER; &PREFIX&I %END;
%MEND NAMES;


%*Counting the number of words in a string (SAS macro manual, p.256);
%MACRO WORDS(STRING);
  %LOCAL COUNT WORD;
  %LET COUNT=1;
  %LET WORD=%QSCAN(&STRING,&COUNT,%STR( ));
  %DO %WHILE(&WORD NE);
    %LET COUNT=%EVAL(&COUNT+1);
    %LET WORD=%QSCAN(&STRING,&COUNT,%STR( ));
  %END;
  %EVAL(&COUNT-1)
%MEND WORDS;


%*Generating the formula for the restricted cubic splines;
%*WI ... number of the current covariable;
%*WK ... number of knots;
%*WKNOTS ... knots;
%*WNAME ... prefix for the generated extra variables;
%*WSTAT ... information whether PHREG (1) or IML (2) 
            are calling this routine;
%*WM ... reference value for fixed covariate (if WHAT=0);
%MACRO RCUBSPL (WI,WK,WKNOTS,WNAME,WSTAT=1,WM=);
  %LOCAL C C3 CC S J WK_1;
  %LOCAL %NAMES(&WK,PREFIX=T);
  %DO J=1 %TO &WK;		
    %LET T&J=%QSCAN(&WKNOTS,&J,%STR( )); 
  %END;
  %IF &WSTAT=1 %THEN %DO; 
    %LET C=*; %LET C3=**3; %LET S=__&WI._;
  %END; 
  %ELSE %DO;
    %LET C=#; %LET C3=##3; %LET S=S;
  %END;
  %IF &WSTAT=2 %THEN %DO;
    %IF &WM NE %THEN %DO;
      PUT " LOWEREND=&T1;     *Smallest value for X-axis; ";
      PUT " UPPEREND=&&T&WK;     *Largest value for X-axis; ";
      PUT " REF=(&T1+&&T&WK)/2;     *Reference value for X-axis; ";     
    %END;
    %ELSE %DO;
      PUT " LOWEREND=0;     *Smallest value for X-axis; ";
      PUT " UPPEREND=&&T&WK;     *Largest value for X-axis; ";
    %END;
    PUT " &WNAME=T(DO(LOWEREND,UPPEREND," @;
    PUT "(UPPEREND-LOWEREND)/(NPOINTS-1))); ";
  %END;
  %LET WK_1=%EVAL(&WK-1);
  %DO J=1 %TO %EVAL(&WK-2);		
    PUT " &S.&J=((&WNAME-&&T&J)&C3)&C(&WNAME>&&T&J) ";
    PUT "     -((&WNAME-&&T&WK_1)&C3)&C(&WNAME>&&T&WK_1) ";
    PUT "     &C(&&T&WK-&&T&J)/(&&T&WK-&&T&WK_1) ";
    PUT "     +((&WNAME-&&T&WK)&C3)&C(&WNAME>&&T&WK) ";
    PUT "     &C(&&T&WK_1-&&T&J)/(&&T&WK-&&T&WK_1)" @ ;
    %IF &WM NE %THEN %DO;
      PUT " ";
      PUT "     -((&WM-&&T&J)&C3)&C(&WM>&&T&J) ";
      PUT "     +((&WM-&&T&WK_1)&C3)&C(&WM>&&T&WK_1)" @ ;
      PUT "&C(&&T&WK-&&T&J)/(&&T&WK-&&T&WK_1) ";
      PUT "     -((&WM-&&T&WK)&C3)&C(&WM>&&T&WK)" @ ;
      PUT "&C(&&T&WK_1-&&T&J)/(&&T&WK-&&T&WK_1); ";
    %END;
    %ELSE %DO; PUT "; " ; %END;
  %END;
%MEND RCUBSPL;


%*Generating the PROC GPLOT statements;
%*RGSTATUS ... information whether the log hazard ratio function (0)
               or the hazard ratio function (1) should be plotted;
%*RGI ... number of the current covariable;
%*RGCOV ... current covariable;
%*RGWHAT ... WHAT-statement of the current covariable;
%*RGTU ... TIMEUNIT-statement;
%MACRO RGRA(RGSTATUS,RGI,RGCOV,RGWHAT,RGTU);
  PUT "PROC GPLOT DATA=__RCS&RGI; "; 
  PUT " PLOT " @ ;
  %IF &RGSTATUS EQ 0 %THEN %DO; PUT "F" @ ; %END; 
  %ELSE                    %DO; PUT "FE" @ ; %END;		  
  PUT "*X=Z / VREF=&RGSTATUS LV=3 NOLEGEND; ";
  PUT " TITLE2 ' &RGCOV '; ";
  %IF &RGWHAT EQ 0 %THEN %DO;
    PUT " LABEL X=&RGCOV; ";
  %END;
  %ELSE %DO;
    %IF &RGWHAT EQ 1 %THEN %DO;  
      PUT " LABEL X=&RGTU; ";
    %END;
    %ELSE %DO;  
      PUT " LABEL X=&RGTU SINCE BINARY TIME-DEP. EVENT; ";
    %END;    
  %END;
  %IF &RGSTATUS EQ 0 %THEN %DO; PUT " LABEL F=LOG HAZARD RATIO; "; %END;
  %ELSE %DO; PUT " LABEL FE=HAZARD RATIO; "; %END;
  PUT " RUN; ";
  PUT " ods pdf close; ";
  PUT " quit; ";

  PUT " ";
%MEND RGRA;
