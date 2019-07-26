/************************************************************/
/* DATAPREP Macro								 		    */
/************************************************************/
/* Code to "Utilizing PROC CONTENTS with Macro Programming  */
/* to Summarize and Tabulate Copious Amounts of Data		*/
/* See MWSUG RF-02-2016 paper for more information			*/
/* This macro will evaluate a list of datasets, and run   	*/
/* frequency tables on all variables existing- except for	*/
/* specific exclusions specified by user or have a variable */
/* length not equal to 1. 									*/
*************************************************************/
/*MACRO PROMPTS: 											*/
/*DATA = Add a list of datasets of interest only separating */
/*		 by space.											*/
/*EXCLUDE_VARS = Include a list of variables that should 	*/
/*		be excluded	from a PROC FREQ analysis by including  */
/*		them inside of a %str() and using quotes, 			*/
/*		separating by a comma.							 	*/
/*Example: 													*/
/*%DATAPREP(DATA= ds1 ds2 ds3 ds4, 							*/
/*EXCLUDE_VARS = %str(subject_ID, text_field1, textfield2");*/
/************************************************************/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


%MACRO DATAPREP(DATA=, EXCLUDE_VARS=);
     %LET Dataset_Count=%SYSFUNC(COUNTW(&DATA));
	%DO i = 1 %TO &Dataset_Count.;
 	
	PROC CONTENTS DATA = %SCAN(&DATA,&i) NOPRINT OUT = Contents_%SCAN(&DATA,&i); 
		RUN;
	  
		DATA Contents_%SCAN(&DATA,&i); 
			SET Contents_%SCAN(&DATA,&i);
			/* Change or remove the following line if 
			desired output changes*/    
			IF Length NE 1 THEN DELETE; 
			IF Name in (&EXCLUDE_VARS) THEN DELETE;
			Label = Name;
			KEEP Name VarNum Label;
		RUN;
		%GLOBAL List_%SCAN(&DATA,&i);

		PROC SQL NOPRINT; 
			SELECT DISTINCT Name
			INTO :List_%SCAN(&DATA,&i) SEPARATED BY ' '
			FROM Contents_%SCAN(&DATA,&i)
			ORDER BY VarNum;
		QUIT; 

		%GLOBAL Count%SCAN(&DATA,&i);

		%LET Count%SCAN(&DATA,&i) = &SQLOBS; 

		%LET Countvar=Count%SCAN(&DATA,&i);
		%LET Count=&&&Countvar; 

		%LET Listvar = List_%SCAN(&DATA,&i); 
		%LET List = &&&Listvar; 

	/*Data specific changes should be made in below data step*/   
	DATA %SCAN(&DATA,&i); 
			SET %SCAN(&DATA,&i); 
			ARRAY %SCAN(&DATA,&i) [&Count] &List;
			DO j = 1 TO &Count; 
			IF %SCAN(&DATA,&i)(j) = '' or
			%SCAN(&DATA,&i)(j) = 'U'
			THEN %SCAN(&DATA,&i)(j) = 'A';
				ELSE %SCAN(&DATA,&i)(j) = 'P';
			END;
			FORMAT &List $Issues.; 
		RUN; 
	/* Analysis output types can be changed below */
		PROC FREQ DATA = %SCAN(&DATA,&i); 
			TABLES DeathCause*(&List) /CHISQ; 
			TITLE "%SCAN(&DATA,&i) Issues";
		RUN; 

		%END; 
%MEND; 

%DATAPREP(DATA = Social Culture Environment FamPlan FetalMed Injuries MentalHealth Mother Payment Pediatric Preconception Prenatal Service Substance Transitions Transport Violence, EXCLUDE_VARS = %str('Fetal__F__Infant__I_','Other'));
