/************************************************************/
/* See MWSUG 2014 paper RF-07-2014, "Color Me Impressed:.." */
/* for more information.								    */
/* Provides example and code to create coloring in PROC     */
/* only on the matrix diagonal.								*/
/* By: Erica Goodrich										*/
/************************************************************/

/*Example Data set*/
DATA hosp_admit;
INPUT admission readmission;
CARDS;
0 4
0 5
2 3
1 2
0 1
0 0
1 2
1 1
0 0
;

/*Formatted values for admission and readmission variables*/
PROC FORMAT;
VALUE readmitf
 0 = "Readmitted within 30"
 1 = "Readmitted between 31 and 60"
 2 = "Readmitted between 61 and 90"
 3 = "Readmitted between 91 and 120"
 4 = "Readmitted between 121 and 150"
 5 = "Readmitted after 151";
VALUE hospf
 0 = "Hospitalized in 30 days"
 1 = "Hospitalized in month 1"
 2 = "Hospitalized in month 2"
 3 = "Hospitalized in month 3"
 4 = "Hospitalized in month 4"
 5 = "Hospitalized GE month 5";
RUN;

/*Coloring macro*/
%MACRO DIAG_COLORS(Start, Columns, Color,);
	%LET J = 0;
	%DO I = &Start %TO &Columns;
		%LET J = %SYSEVALF(&J + 1);
		IF admission = (-1 + &J) and _COL_ = (&start+ &J) THEN DO;
			CALL DEFINE(_COL_,'style',"STYLE={background=&color}");
		END;
	%END;
%MEND;

/*Finalized PROC REPORT with diagonal coloring*/
/*ods rtf style=meadow;*/
PROC REPORT DATA=hosp_admit NOWD COMPLETEROWS COMPLETECOLS MISSING SPLIT='*';
	COLUMN admission readmission;
	DEFINE admission / '' GROUP FORMAT=hospf. PRELOADFMT ORDER=data
	STYLE(column)=[just=c width=.6in];
	DEFINE readmission / '' ACROSS FORMAT=readmitf. PRELOADFMT ORDER=data
	STYLE(column)=[just=c width=.8in];
RUN;
QUIT;

PROC REPORT DATA=hosp_admit NOWD COMPLETEROWS COMPLETECOLS MISSING SPLIT='*';
	COLUMN admission readmission;
	DEFINE admission / '' GROUP FORMAT=hospf. PRELOADFMT ORDER=data
	STYLE(column)=[just=c width=.6in];
	DEFINE readmission / '' ACROSS FORMAT=readmitf. PRELOADFMT ORDER=data
	STYLE(column)=[just=c width=.8in];
	COMPUTE readmission;
		IF _col_ = 2 THEN DO;
			CALL DEFINE(_col_,'style','style={background=yellow}');
		END;
	ENDCOMP;
RUN;
QUIT;

PROC REPORT DATA=hosp_admit NOWD COMPLETEROWS COMPLETECOLS MISSING SPLIT='*';
	COLUMN admission readmission;
	DEFINE admission / '' GROUP FORMAT=hospf. PRELOADFMT ORDER=data
	STYLE(column)=[just=c width=.6in];
	DEFINE readmission / '' ACROSS FORMAT=readmitf. PRELOADFMT ORDER=data
	STYLE(column)=[just=c width=.8in];
	COMPUTE readmission;
		IF admission = 0 THEN DO;
			CALL DEFINE(_col_,'style','style={background=yellow}');
		END;
	ENDCOMP;
RUN;
QUIT;

PROC REPORT DATA=hosp_admit NOWD COMPLETEROWS COMPLETECOLS MISSING SPLIT='*';
	COLUMN admission readmission;
	DEFINE admission / '' GROUP FORMAT=hospf. PRELOADFMT ORDER=data
	STYLE(column)=[just=c width=.6in];
	DEFINE readmission / '' ACROSS FORMAT=readmitf. PRELOADFMT ORDER=data
	STYLE(column)=[just=c width=.8in];
		COMPUTE readmission;
			IF admission = 0 and _col_ = 2 THEN DO;
				CALL DEFINE(_col_,'style','style={background=yellow}');
			END;
		ENDCOMP;
RUN;
QUIT;

PROC REPORT DATA=hosp_admit NOWD COMPLETEROWS COMPLETECOLS MISSING SPLIT='*';
	 COLUMN admission readmission;
	 DEFINE admission / '' GROUP FORMAT=hospf. PRELOADFMT ORDER=data
	 STYLE(column)=[just=c width=.6in];
	 DEFINE readmission / '' ACROSS FORMAT=readmitf. PRELOADFMT ORDER=data
	 STYLE(column)=[just=c width=.8in];
	 COMPUTE readmission;
		 /*First diagonal - yellow*/
		 %DIAG_COLORS(1,6, yellow);
		 /*Second diagonal - teal*/
		 %DIAG_COLORS(2,6, teal);
		 /*Third diagonal - pink*/
		 %DIAG_COLORS(3,6, pink);
		 /*Forth diagonal - brown*/
		 %DIAG_COLORS(4,6, CXA66921);
		 /*Fifth diagonal - peach*/
		 %DIAG_COLORS(5,6, CXFA8072);
		 /*Sixth diagonal - blue*/
		 %DIAG_COLORS(6,6,light blue);
 	ENDCOMP;
 RUN;
 QUIT;
/*ods rtf close;*/
